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

            return res.json({
                alerts,
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
