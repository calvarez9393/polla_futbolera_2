/** Letra de grupo (A–L) desde nombre en BD («Grupo A») o ranura FIFA («A»). */
export function groupLetterFromName(name: string): string {
  const trimmed = name.trim();
  const fromGrupo = trimmed.match(/^grupo\s+([A-L])$/i);
  if (fromGrupo) return fromGrupo[1].toUpperCase();
  if (/^[A-L]$/i.test(trimmed)) return trimmed.toUpperCase();
  return trimmed.toUpperCase();
}
