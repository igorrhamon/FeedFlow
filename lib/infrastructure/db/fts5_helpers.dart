import 'dart:convert';

/// Remove tags HTML de um texto, mantendo o conteúdo entre as tags.
/// Útil para preparar o conteúdo para indexação FTS5.
String stripHtmlTags(String? html) {
  if (html == null || html.isEmpty) return '';

  // Remove tags HTML simples: <tag>...</tag>, <tag ... />
  final noTags = html.replaceAll(RegExp(r'<[^>]+>'), ' ');

  // Decodifica entidades HTML comuns
  return _decodeHtmlEntities(noTags).trim();
}

/// Decodifica entidades HTML como &nbsp;, &lt;, &gt;, &amp;, &quot;, &#123;, etc.
String _decodeHtmlEntities(String text) {
  return text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&') // Deve ser depois dos outros &*;
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&#x27;', "'");
}

/// Converte JSON de tags (ex.: ["a","b","c"]) para string separada por espaço.
/// Útil para alimentar uma coluna de texto plano no FTS5.
String tagsJsonToPlaintext(String tagsJson) {
  if (tagsJson.isEmpty || tagsJson == '[]') return '';
  try {
    final tags = jsonDecode(tagsJson) as List<dynamic>;
    return tags.map((t) => t.toString()).join(' ');
  } catch (e) {
    return '';
  }
}
