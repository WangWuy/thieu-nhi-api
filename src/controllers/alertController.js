const { prisma } = require('../../prisma/client');

const parsePagination = (query) => {
    const page = Math.max(parseInt(query.page || '1', 10), 1);
    const limit = Math.min(Math.max(parseInt(query.limit || '20', 10), 1), 200);
    const skip = (page - 1) * limit;
    return { page, limit, skip };
};

const parseTimeRange = (timeRange = '7days') => {
    const now = new Date();
    const daysMap = {
        '1day': 1,
        '7days': 7,
        '30days': 30,
        '90days': 90,
        'all': null
    };
    const days = daysMap[timeRange] ?? 7;
    if (!days) return null;
    return new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
};

const alertController = {
    async getAlerts(req, res) {
        try {
            const { priority, status, type, timeRange } = req.query;
            const { page, limit, skip } = parsePagination(req.query);

            const where = {};
            if (priority && priority !== 'all') where.priority = priority;
            if (status && status !== 'all') where.status = status;
            if (type && type !== 'all') where.type = type;

            const cutoff = parseTimeRange(timeRange);
            if (cutoff) {
                where.createdAt = { gte: cutoff };
            }

            const [alerts, total, unread, high, resolved] = await Promise.all([
                prisma.systemAlert.findMany({
                    where,
                    orderBy: { createdAt: 'desc' },
                    skip,
                    take: limit
                }),
                prisma.systemAlert.count({ where }),
                prisma.systemAlert.count({ where: { ...where, status: 'unread' } }),
                prisma.systemAlert.count({ where: { ...where, priority: 'high' } }),
                prisma.systemAlert.count({ where: { ...where, status: 'resolved' } })
            ]);

            // Enrich alerts with student/class info if present in data
            const studentIds = new Set();
            const classIds = new Set();
            alerts.forEach(al => {
                const sid = al.data?.studentId;
                const cid = al.data?.classId;
                if (sid) studentIds.add(sid);
                if (cid) classIds.add(cid);
            });

            const [students, classes] = await Promise.all([
                studentIds.size ? prisma.student.findMany({
                    where: { id: { in: Array.from(studentIds) } },
                    select: {
                        id: true,
                        studentCode: true,
                        fullName: true,
                        class: { select: { id: true, name: true, departmentId: true } }
                    }
                }) : [],
                classIds.size ? prisma.class.findMany({
                    where: { id: { in: Array.from(classIds) } },
                    select: { id: true, name: true, departmentId: true }
                }) : []
            ]);

            const studentMap = new Map(students.map(s => [s.id, s]));
            const classMap = new Map(classes.map(c => [c.id, c]));

            const enrichedAlerts = alerts.map(al => {
                const extra = {};
                if (al.data?.studentId && studentMap.has(al.data.studentId)) {
                    extra.student = studentMap.get(al.data.studentId);
                }
                if (al.data?.classId && classMap.has(al.data.classId)) {
                    extra.class = classMap.get(al.data.classId);
                }
                return { ...al, ...extra };
            });

            return res.json({
                alerts: enrichedAlerts,
                stats: {
                    total,
                    unread,
                    high,
                    resolved
                },
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            });
        } catch (error) {
            console.error('Get alerts error:', error);
            return res.status(500).json({ error: 'Không thể tải danh sách cảnh báo' });
        }
    },

    async createAlert(req, res) {
        try {
            const { type, priority, title, message, source = 'system', data, ruleId } = req.body;
            if (!type || !priority || !title || !message) {
                return res.status(400).json({ error: 'Thiếu trường bắt buộc (type, priority, title, message)' });
            }

            const alert = await prisma.systemAlert.create({
                data: {
                    type,
                    priority,
                    title,
                    message,
                    source,
                    data: data || null,
                    ruleId: ruleId || null
                }
            });

            return res.status(201).json(alert);
        } catch (error) {
            console.error('Create alert error:', error);
            return res.status(500).json({ error: 'Không thể tạo cảnh báo' });
        }
    },

    async markRead(req, res) {
        try {
            const { id } = req.params;
            const alert = await prisma.systemAlert.update({
                where: { id: parseInt(id, 10) },
                data: { status: 'read' }
            });
            return res.json(alert);
        } catch (error) {
            console.error('Mark read error:', error);
            return res.status(500).json({ error: 'Không thể cập nhật cảnh báo' });
        }
    },

    async markResolved(req, res) {
        try {
            const { id } = req.params;
            const alert = await prisma.systemAlert.update({
                where: { id: parseInt(id, 10) },
                data: { status: 'resolved' }
            });
            return res.json(alert);
        } catch (error) {
            console.error('Mark resolved error:', error);
            return res.status(500).json({ error: 'Không thể cập nhật cảnh báo' });
        }
    },

    async deleteAlert(req, res) {
        try {
            const { id } = req.params;
            await prisma.systemAlert.delete({ where: { id: parseInt(id, 10) } });
            return res.json({ success: true });
        } catch (error) {
            console.error('Delete alert error:', error);
            return res.status(500).json({ error: 'Không thể xóa cảnh báo' });
        }
    },

    // Evaluate enabled rules against current data and create alerts automatically
    async evaluateRules(req, res) {
        try {
            const days = parseInt(req.query.days || '30', 10) || 30; // look-back window
            const sinceDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

            const rules = await prisma.alertRule.findMany({
                where: { enabled: true },
                orderBy: { createdAt: 'desc' }
            });

            const createdAlerts = [];

            // Support attendance_rate rule for now
            const attendanceRules = rules.filter(r =>
                r.type === 'attendance' &&
                r.condition.toLowerCase().includes('attendance_rate')
            );
            if (attendanceRules.length) {
                const [totalAttendance, presentAttendance] = await Promise.all([
                    prisma.attendance.count({
                        where: {
                            attendanceDate: { gte: sinceDate }
                        }
                    }),
                    prisma.attendance.count({
                        where: {
                            attendanceDate: { gte: sinceDate },
                            isPresent: true
                        }
                    })
                ]);

                const attendanceRate = totalAttendance ? presentAttendance / totalAttendance : 1;

                for (const rule of attendanceRules) {
                    if (attendanceRate < rule.threshold) {
                        // Avoid spamming: skip if unresolved alert for this rule in window
                        const existing = await prisma.systemAlert.findFirst({
                            where: {
                                ruleId: rule.id,
                                status: { in: ['unread', 'read'] },
                                createdAt: { gte: sinceDate }
                            }
                        });
                        if (existing) continue;

                        const alert = await prisma.systemAlert.create({
                            data: {
                                type: 'attendance',
                                priority: rule.priority,
                                title: 'Tỷ lệ điểm danh thấp',
                                message: `Tỷ lệ điểm danh ${Math.round(attendanceRate * 1000) / 10}% trong ${days} ngày qua thấp hơn ngưỡng ${Math.round(rule.threshold * 1000) / 10}%`,
                                source: 'rule_engine',
                                data: {
                                    attendanceRate,
                                    totalAttendance,
                                    presentAttendance,
                                    windowDays: days,
                                    ruleId: rule.id
                                },
                                ruleId: rule.id
                            }
                        });
                        createdAlerts.push(alert);
                    }
                }
            }

            // Support study/final score rules (grades)
            const gradeRules = rules.filter(r =>
                r.type === 'grades' &&
                (r.condition.toLowerCase().includes('study_score') ||
                    r.condition.toLowerCase().includes('final_score'))
            );

            if (gradeRules.length) {
                const gradeAgg = await prisma.student.aggregate({
                    _avg: {
                        finalAverage: true,
                        studyAverage: true
                    },
                    where: { isActive: true }
                });

                const avgFinal = gradeAgg._avg.finalAverage ? Number(gradeAgg._avg.finalAverage) : 0;
                const avgStudy = gradeAgg._avg.studyAverage ? Number(gradeAgg._avg.studyAverage) : 0;

                for (const rule of gradeRules) {
                    const value = rule.condition.toLowerCase().includes('final_score')
                        ? avgFinal
                        : avgStudy;

                    if (value < rule.threshold) {
                        const existing = await prisma.systemAlert.findFirst({
                            where: {
                                ruleId: rule.id,
                                status: { in: ['unread', 'read'] },
                                createdAt: { gte: sinceDate }
                            }
                        });
                        if (existing) continue;

                        const alert = await prisma.systemAlert.create({
                            data: {
                                type: 'grades',
                                priority: rule.priority,
                                title: 'Điểm học tập thấp',
                                message: `Điểm trung bình ${Math.round(value * 10) / 10} thấp hơn ngưỡng ${Math.round(rule.threshold * 10) / 10}`,
                                source: 'rule_engine',
                                data: {
                                    averageFinal: avgFinal,
                                    averageStudy: avgStudy,
                                    windowDays: days,
                                    ruleId: rule.id
                                },
                                ruleId: rule.id
                            }
                        });
                        createdAlerts.push(alert);
                    }
                }
            }

            // Per-student grade rules (student_final_score, student_study_score)
            const studentGradeRules = rules.filter(r =>
                r.type === 'grades' &&
                (r.condition.toLowerCase().includes('student_final_score') ||
                    r.condition.toLowerCase().includes('student_study_score'))
            );

            if (studentGradeRules.length) {
                const students = await prisma.student.findMany({
                    where: { isActive: true },
                    select: {
                        id: true,
                        studentCode: true,
                        fullName: true,
                        finalAverage: true,
                        studyAverage: true,
                        class: { select: { id: true, name: true, departmentId: true } }
                    }
                });

                for (const student of students) {
                    for (const rule of studentGradeRules) {
                        const useFinal = rule.condition.toLowerCase().includes('student_final_score');
                        const value = useFinal
                            ? Number(student.finalAverage || 0)
                            : Number(student.studyAverage || 0);

                        if (value < rule.threshold) {
                            const existing = await prisma.systemAlert.findFirst({
                                where: {
                                    ruleId: rule.id,
                                    status: { in: ['unread', 'read'] },
                                    createdAt: { gte: sinceDate },
                                    data: {
                                        path: ['studentId'],
                                        equals: student.id
                                    }
                                }
                            });
                            if (existing) continue;

                            const alert = await prisma.systemAlert.create({
                                data: {
                                    type: 'grades',
                                    priority: rule.priority,
                                    title: `Điểm học tập thấp - ${student.fullName}`,
                                    message: `${useFinal ? 'Điểm tổng' : 'Điểm học'} của ${student.fullName} là ${Math.round(value * 10) / 10}, thấp hơn ngưỡng ${Math.round(rule.threshold * 10) / 10}`,
                                    source: 'rule_engine',
                                    data: {
                                        studentId: student.id,
                                        studentCode: student.studentCode,
                                        studentName: student.fullName,
                                        classId: student.class?.id,
                                        className: student.class?.name,
                                        scoreType: useFinal ? 'final' : 'study',
                                        score: value,
                                        threshold: rule.threshold,
                                        windowDays: days,
                                        ruleId: rule.id
                                    },
                                    ruleId: rule.id
                                }
                            });
                            createdAlerts.push(alert);
                        }
                    }
                }
            }

            // Support simple system rule: class_size < threshold
            const systemRules = rules.filter(r =>
                r.type === 'system' &&
                r.condition.toLowerCase().includes('class_size')
            );

            if (systemRules.length) {
                const classes = await prisma.class.findMany({
                    include: {
                        department: true,
                        _count: { select: { students: true } }
                    }
                });

                for (const cls of classes) {
                    for (const rule of systemRules) {
                        if (cls._count.students < rule.threshold) {
                            const existing = await prisma.systemAlert.findFirst({
                                where: {
                                    ruleId: rule.id,
                                    status: { in: ['unread', 'read'] },
                                    createdAt: { gte: sinceDate },
                                    data: {
                                        path: ['classId'],
                                        equals: cls.id
                                    }
                                }
                            });
                            if (existing) continue;

                            const alert = await prisma.systemAlert.create({
                                data: {
                                    type: 'system',
                                    priority: rule.priority,
                                    title: `Lớp sĩ số thấp - ${cls.name}`,
                                    message: `Lớp ${cls.name} chỉ có ${cls._count.students} thiếu nhi, thấp hơn ngưỡng ${rule.threshold}`,
                                    source: 'rule_engine',
                                    data: {
                                        classId: cls.id,
                                        className: cls.name,
                                        departmentId: cls.departmentId,
                                        departmentName: cls.department?.displayName,
                                        studentCount: cls._count.students,
                                        ruleId: rule.id
                                    },
                                    ruleId: rule.id
                                }
                            });
                            createdAlerts.push(alert);
                        }
                    }
                }
            }

            // Per-student attendance rules (student_attendance_rate, consecutive_absent)
            const studentRateRules = rules.filter(r =>
                r.type === 'attendance' &&
                r.condition.toLowerCase().includes('student_attendance_rate')
            );
            const consecutiveRules = rules.filter(r =>
                r.type === 'attendance' &&
                r.condition.toLowerCase().includes('consecutive_absent')
            );

            if (studentRateRules.length || consecutiveRules.length) {
                const attendanceRecords = await prisma.attendance.findMany({
                    where: { attendanceDate: { gte: sinceDate } },
                    select: { studentId: true, attendanceDate: true, isPresent: true }
                });

                const studentStats = new Map();

                attendanceRecords.forEach(rec => {
                    if (!studentStats.has(rec.studentId)) {
                        studentStats.set(rec.studentId, {
                            total: 0,
                            present: 0,
                            records: []
                        });
                    }
                    const stat = studentStats.get(rec.studentId);
                    stat.total += 1;
                    stat.present += rec.isPresent ? 1 : 0;
                    stat.records.push({
                        date: rec.attendanceDate,
                        isPresent: rec.isPresent
                    });
                });

                // Fetch student details for alerts
                const studentIds = Array.from(studentStats.keys());
                const students = studentIds.length
                    ? await prisma.student.findMany({
                        where: { id: { in: studentIds } },
                        select: {
                            id: true,
                            studentCode: true,
                            fullName: true,
                            class: { select: { id: true, name: true } }
                        }
                    })
                    : [];
                const studentMap = new Map(students.map(s => [s.id, s]));

                // Compute streaks and rates
                for (const [studentId, stat] of studentStats.entries()) {
                    // student_attendance_rate rules
                    if (studentRateRules.length && stat.total > 0) {
                        const rate = stat.present / stat.total;
                        for (const rule of studentRateRules) {
                            if (rate < rule.threshold) {
                                const existing = await prisma.systemAlert.findFirst({
                                    where: {
                                        ruleId: rule.id,
                                        status: { in: ['unread', 'read'] },
                                        createdAt: { gte: sinceDate },
                                        data: {
                                            path: ['studentId'],
                                            equals: studentId
                                        }
                                    }
                                });
                                if (existing) continue;

                                const student = studentMap.get(studentId);
                                const alert = await prisma.systemAlert.create({
                                    data: {
                                        type: 'attendance',
                                        priority: rule.priority,
                                        title: `Thiếu nhi điểm danh thấp${student ? ` - ${student.fullName}` : ''}`,
                                        message: `Tỷ lệ điểm danh ${Math.round(rate * 1000) / 10}% trong ${days} ngày qua thấp hơn ngưỡng ${Math.round(rule.threshold * 1000) / 10}%`,
                                        source: 'rule_engine',
                                        data: {
                                            studentId,
                                            studentCode: student?.studentCode,
                                            studentName: student?.fullName,
                                            classId: student?.class?.id,
                                            className: student?.class?.name,
                                            attendanceRate: rate,
                                            totalAttendance: stat.total,
                                            presentAttendance: stat.present,
                                            windowDays: days,
                                            ruleId: rule.id
                                        },
                                        ruleId: rule.id
                                    }
                                });
                                createdAlerts.push(alert);
                            }
                        }
                    }

                    // consecutive_absent rules
                    if (consecutiveRules.length && stat.records.length) {
                        const sorted = stat.records.sort((a, b) => new Date(b.date) - new Date(a.date));
                        let currentStreak = 0;
                        let maxStreak = 0;
                        for (const rec of sorted) {
                            if (rec.isPresent) {
                                currentStreak = 0;
                            } else {
                                currentStreak += 1;
                                maxStreak = Math.max(maxStreak, currentStreak);
                            }
                        }

                        for (const rule of consecutiveRules) {
                            if (maxStreak >= rule.threshold) {
                                const existing = await prisma.systemAlert.findFirst({
                                    where: {
                                        ruleId: rule.id,
                                        status: { in: ['unread', 'read'] },
                                        createdAt: { gte: sinceDate },
                                        data: {
                                            path: ['studentId'],
                                            equals: studentId
                                        }
                                    }
                                });
                                if (existing) continue;

                                const student = studentMap.get(studentId);
                                const alert = await prisma.systemAlert.create({
                                    data: {
                                        type: 'attendance',
                                        priority: rule.priority,
                                        title: `Vắng liên tục - ${student?.fullName || 'Học sinh'}`,
                                        message: `${student?.fullName || 'Học sinh'} vắng ${maxStreak} buổi liên tục trong ${days} ngày qua.`,
                                        source: 'rule_engine',
                                        data: {
                                            studentId,
                                            studentCode: student?.studentCode,
                                            studentName: student?.fullName,
                                            classId: student?.class?.id,
                                            className: student?.class?.name,
                                            consecutiveAbsent: maxStreak,
                                            windowDays: days,
                                            ruleId: rule.id
                                        },
                                        ruleId: rule.id
                                    }
                                });
                                createdAlerts.push(alert);
                            }
                        }
                    }
                }
            }

            return res.json({
                created: createdAlerts.length,
                alerts: createdAlerts
            });
        } catch (error) {
            console.error('Evaluate rules error:', error);
            return res.status(500).json({ error: 'Không thể đánh giá quy tắc' });
        }
    },

    // ===== Rules =====
    async getRules(req, res) {
        try {
            const rules = await prisma.alertRule.findMany({
                orderBy: { createdAt: 'desc' }
            });
            return res.json(rules);
        } catch (error) {
            console.error('Get rules error:', error);
            return res.status(500).json({ error: 'Không thể tải quy tắc cảnh báo' });
        }
    },

    async createRule(req, res) {
        try {
            const { name, type, condition, threshold, priority = 'medium', enabled = true, notification = [], description } = req.body;
            if (!name || !type || !condition || threshold === undefined || threshold === null) {
                return res.status(400).json({ error: 'Thiếu trường bắt buộc (name, type, condition, threshold)' });
            }

            const rule = await prisma.alertRule.create({
                data: {
                    name,
                    type,
                    condition,
                    threshold: parseFloat(threshold),
                    priority,
                    enabled,
                    notification,
                    description
                }
            });

            return res.status(201).json(rule);
        } catch (error) {
            console.error('Create rule error:', error);
            return res.status(500).json({ error: 'Không thể tạo quy tắc' });
        }
    },

    async updateRule(req, res) {
        try {
            const { id } = req.params;
            const { name, type, condition, threshold, priority, enabled, notification, description } = req.body;

            const rule = await prisma.alertRule.update({
                where: { id: parseInt(id, 10) },
                data: {
                    ...(name !== undefined && { name }),
                    ...(type !== undefined && { type }),
                    ...(condition !== undefined && { condition }),
                    ...(threshold !== undefined && { threshold: parseFloat(threshold) }),
                    ...(priority !== undefined && { priority }),
                    ...(enabled !== undefined && { enabled }),
                    ...(notification !== undefined && { notification }),
                    ...(description !== undefined && { description })
                }
            });

            return res.json(rule);
        } catch (error) {
            console.error('Update rule error:', error);
            return res.status(500).json({ error: 'Không thể cập nhật quy tắc' });
        }
    },

    async toggleRule(req, res) {
        try {
            const { id } = req.params;
            const existing = await prisma.alertRule.findUnique({ where: { id: parseInt(id, 10) } });
            if (!existing) return res.status(404).json({ error: 'Không tìm thấy quy tắc' });

            const rule = await prisma.alertRule.update({
                where: { id: existing.id },
                data: { enabled: !existing.enabled }
            });

            return res.json(rule);
        } catch (error) {
            console.error('Toggle rule error:', error);
            return res.status(500).json({ error: 'Không thể chuyển trạng thái quy tắc' });
        }
    },

    async deleteRule(req, res) {
        try {
            const { id } = req.params;
            await prisma.alertRule.delete({ where: { id: parseInt(id, 10) } });
            return res.json({ success: true });
        } catch (error) {
            console.error('Delete rule error:', error);
            return res.status(500).json({ error: 'Không thể xóa quy tắc' });
        }
    }
};

module.exports = alertController;
