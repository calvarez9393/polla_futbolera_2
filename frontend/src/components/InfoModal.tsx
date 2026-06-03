import { useState, type ReactNode } from "react";
import { Modal } from "./Modal";

interface InfoModalProps {
  title: string;
  children: ReactNode;
  /** Texto del botón; por defecto solo icono */
  triggerLabel?: string;
  className?: string;
}

export function InfoModal({ title, children, triggerLabel, className = "" }: InfoModalProps) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button
        type="button"
        className={`info-modal-trigger${className ? ` ${className}` : ""}`}
        onClick={() => setOpen(true)}
        aria-label={`Información: ${title}`}
      >
        {triggerLabel ? <span className="info-modal-trigger-label">{triggerLabel}</span> : null}
        <span className="info-modal-trigger-icon" aria-hidden>
          ⓘ
        </span>
      </button>
      <Modal title={title} open={open} onClose={() => setOpen(false)}>
        <div className="info-modal-body">{children}</div>
      </Modal>
    </>
  );
}

interface PageTitleProps {
  children: ReactNode;
  helpTitle: string;
  help: ReactNode;
}

/** Título de página con descripción en modal (sin subtítulo visible). */
export function PageTitle({ children, helpTitle, help }: PageTitleProps) {
  return (
    <div className="page-title-row">
      <h1 className="page-title">{children}</h1>
      <InfoModal title={helpTitle}>{help}</InfoModal>
    </div>
  );
}

interface SectionTitleProps {
  title: string;
  helpTitle?: string;
  help?: ReactNode;
  as?: "h2" | "h3";
  className?: string;
}

/** Encabezado de sección con ayuda opcional en modal. */
export function SectionTitle({ title, helpTitle, help, as: Tag = "h2", className = "" }: SectionTitleProps) {
  const modalTitle = helpTitle ?? title;
  const tagClass = Tag === "h3" ? "section-title section-title--h3" : "section-title";
  return (
    <div className={`section-title-row${className ? ` ${className}` : ""}`}>
      <Tag className={tagClass}>{title}</Tag>
      {help ? <InfoModal title={modalTitle}>{help}</InfoModal> : null}
    </div>
  );
}
