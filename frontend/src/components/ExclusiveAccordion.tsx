import { useEffect, useId, useState, type ReactNode } from "react";

export interface ExclusiveAccordionItem {
  id: string;
  title: ReactNode;
  meta?: ReactNode;
  badge?: ReactNode;
  children: ReactNode;
}

interface ExclusiveAccordionProps {
  items: ExclusiveAccordionItem[];
  /** Fase abierta al cargar; por defecto la primera (solo modo no controlado). */
  defaultOpenId?: string | null;
  /** Modo controlado: fase abierta actual. */
  openId?: string | null;
  onOpenIdChange?: (id: string | null) => void;
  className?: string;
}

export function ExclusiveAccordion({
  items,
  defaultOpenId = null,
  openId: controlledOpenId,
  onOpenIdChange,
  className = ""
}: ExclusiveAccordionProps) {
  const baseId = useId();
  const [internalOpenId, setInternalOpenId] = useState<string | null>(defaultOpenId);
  const isControlled = controlledOpenId !== undefined;
  const openId = isControlled ? controlledOpenId : internalOpenId;

  function setOpenId(next: string | null) {
    if (isControlled) onOpenIdChange?.(next);
    else setInternalOpenId(next);
  }

  useEffect(() => {
    if (isControlled) return;
    if (items.length === 0) {
      setInternalOpenId(null);
      return;
    }
    if (internalOpenId != null && items.some((item) => item.id === internalOpenId)) return;
    setInternalOpenId(defaultOpenId ?? items[0]?.id ?? null);
  }, [items, internalOpenId, defaultOpenId, isControlled]);

  function toggle(id: string) {
    setOpenId(openId === id ? null : id);
  }

  if (items.length === 0) return null;

  return (
    <div className={`exclusive-accordion${className ? ` ${className}` : ""}`}>
      {items.map((item) => {
        const isOpen = openId === item.id;
        const panelId = `${baseId}-panel-${item.id}`;
        const triggerId = `${baseId}-trigger-${item.id}`;

        return (
          <section
            key={item.id}
            className={`exclusive-accordion-item${isOpen ? " exclusive-accordion-item--open" : ""}`}
          >
            <button
              type="button"
              id={triggerId}
              className="exclusive-accordion-trigger"
              aria-expanded={isOpen}
              aria-controls={panelId}
              onClick={() => toggle(item.id)}
            >
              <span className="exclusive-accordion-trigger-main">
                <span className="exclusive-accordion-title">{item.title}</span>
                {item.meta ? <span className="exclusive-accordion-meta">{item.meta}</span> : null}
              </span>
              {item.badge ? <span className="exclusive-accordion-badge">{item.badge}</span> : null}
              <span className="exclusive-accordion-chevron" aria-hidden />
            </button>
            {isOpen ? (
              <div id={panelId} className="exclusive-accordion-panel" role="region" aria-labelledby={triggerId}>
                {item.children}
              </div>
            ) : null}
          </section>
        );
      })}
    </div>
  );
}
