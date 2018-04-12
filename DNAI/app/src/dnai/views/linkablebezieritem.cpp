#include "dnai/link.h"
#include "dnai/app.h"
#include "dnai/eventutilities.h"
#include "dnai/views/linkablebezieritem.h"
#include "dnai/views/canvasnode.h"
#include "dnai/views/genericnode.h"

namespace dnai
{
	namespace views
	{
		LinkableBezierItem::LinkableBezierItem(QQuickItem *parent) : CustomShape(parent), m_currentCurve(nullptr),
			m_linkable(nullptr)
		{
			setAcceptHoverEvents(true);
			setAcceptedMouseButtons(Qt::LeftButton);
			setFlag(ItemAcceptsInputMethod, true);
			m_currentHover = nullptr;
            const auto view = qvariant_cast<QQuickItem *>(Editor::instance().selectedView()->property("currentView"));
            if (!view)
            {
                throw std::runtime_error("No canvas view found!");
            }
            m_canvas = dynamic_cast<CanvasNode *>(view);
		}


		const QColor &LinkableBezierItem::colorLink() const
		{
			return m_borderColor;
		}

		void LinkableBezierItem::mouseMoveEvent(QMouseEvent *event)
		{
            if (m_currentCurve == nullptr) return;
            const auto p(mapToItem(m_canvas->content(), event->pos()));
            m_currentCurve->setP4(p);
            auto qlist = m_canvas->focusManager().findFocused(p);
			if (qlist.size() == 0)
			{
				if (m_currentHover)
				{
					if (!m_currentHover->getLinkable()->isLink())
						m_currentHover->setNormal();
					m_currentHover = nullptr;
				}
				return;
			}
			const auto node = dynamic_cast<GenericNode *>(qlist.at(0));
			if (node && node != getNode())
			{
				const auto p1(mapToItem(node, event->pos()));
				const auto cs = findLinkableBezierItem(node, p1);
				if (cs)
				{
					if (m_currentHover && !m_currentHover->getLinkable()->isLink())
						m_currentHover->setNormal();
					if (cs != m_currentHover)
						m_currentHover = cs;
					m_currentHover->setHover();
				}
				else if (!cs && m_currentHover && !m_currentHover->getLinkable()->isLink())
					m_currentHover->setNormal();
			}
		}

		void LinkableBezierItem::mousePressEvent(QMouseEvent *event)
		{
			if (EventUtilities::isHoverCircle(m_radius, event))
			{
                auto b = new BezierCurve(m_canvas->content());
                b->setPosition(getCanvasPos());
				b->setP1(QPoint(0, 0));
				QColor cb(colorLink());
				b->setFillColor(cb);
				const QColor c((cb.red() < 205 ? cb.red() + 50 : 255),
					(cb.green() < 205 ? cb.green() + 50 : 255),
					(cb.blue() < 205 ? cb.blue() + 50 : 255),
					cb.alpha());
				b->setDottedColor(c);
				m_currentCurve = b;
				if (!m_linkable->isLink())
					setHover();
			}
		}

		void LinkableBezierItem::mouseReleaseEvent(QMouseEvent *event)
		{
			if (event->button() != Qt::LeftButton || m_currentCurve == nullptr)
				return;
            const auto p(mapToItem(m_canvas->content(), event->pos()));
            auto qlist = m_canvas->focusManager().findFocused(p);
			if (qlist.size() == 0)
			{
				delete(m_currentCurve);
				m_currentCurve = nullptr;
				if (!m_linkable->isLink())
                {
                    setNormal();
                }
				afterRealease(nullptr);
				return;
			}
            const auto node = dynamic_cast<GenericNode *>(qlist.at(0));
            if (node && node != getNode())
			{
				const auto p1(mapToItem(node, event->pos()));
				const auto cs = findLinkableBezierItem(node, p1);
				if (cs)
				{
					const auto c = m_linkable->connect(cs->getLinkable(), m_currentCurve);
					if (c == nullptr)
					{
						delete(m_currentCurve);
						setNormal();
					}
					else
					{
						const auto p2(cs->getCanvasPos());
						m_currentCurve->setP4(p2);
						m_currentCurve->setDotted(false);
						m_currentCurve->setBack();
						setLink(c);
					}
					afterRealease(c);
					m_currentCurve = nullptr;
					return;
				}
			}
            else if (node)
            {
                delete(m_currentCurve);
                m_currentCurve = nullptr;
                if (!m_linkable->isLink())
                {
                    setNormal();
                }
                afterRealease(nullptr);
                return;
            }
			setNormal();
			afterRealease(nullptr);
			delete(m_currentCurve);
			m_currentCurve = nullptr;
		}

		void LinkableBezierItem::afterRealease(Link *)
        {}

		void LinkableBezierItem::setHover()
		{
			m_status = LinkStatus::Hover;
		}

		void LinkableBezierItem::setNormal()
		{
			if (m_status == LinkStatus::Normal) return;
			resetShape();
			m_status = LinkStatus::Normal;
		}

		void LinkableBezierItem::setLink(Link *)
		{
			m_status = LinkStatus::Linked;
		}

		void LinkableBezierItem::unlinkAll()
		{
			setNormal();
			auto list = m_linkable->links();
			for (auto i = 0; i < list.size(); i++)
			{
				auto l = list.at(i);
				auto lb = dynamic_cast<LinkableBezierItem *>(dynamic_cast<BaseLinkable *>(l->L1 == m_linkable ? l->L2 : l->L1)->parent());
                if (lb->getLinkable()->links().size() < 2)
                    lb->setNormal();
			}
			m_linkable->unlinkAll();
		}
	}
	
}
