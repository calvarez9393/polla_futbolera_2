export function statusLabel(status: string): string {
  switch (status) {
    case "LIVE":
      return "En vivo";
    case "FINISHED":
      return "Finalizado";
    default:
      return "Programado";
  }
}

export function statusBadgeClass(status: string): string {
  switch (status) {
    case "LIVE":
      return "badge badge-live";
    case "FINISHED":
      return "badge badge-finished";
    default:
      return "badge badge-scheduled";
  }
}

function statusCardModifier(prefix: string, status: string): string {
  switch (status) {
    case "FINISHED":
      return ` ${prefix}--finished`;
    case "LIVE":
      return ` ${prefix}--live`;
    default:
      return ` ${prefix}--scheduled`;
  }
}

/** Clases de color por estado (Mundial 2026) en tarjetas de partido. */
export function matchCardStatusClass(status: string): string {
  return statusCardModifier("match-card", status);
}

export function adminMatchStatusClass(status: string): string {
  return statusCardModifier("admin-match-card", status);
}

/** @deprecated Usa matchCardStatusClass */
export function matchFinishedClass(status: string): string {
  return status === "FINISHED" ? " match-card--finished" : "";
}

/** @deprecated Usa adminMatchStatusClass */
export function adminMatchFinishedClass(status: string): string {
  return status === "FINISHED" ? " admin-match-card--finished" : "";
}
