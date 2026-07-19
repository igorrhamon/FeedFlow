/// Prompts compartilhados pelos adapters de LLM (Anthropic, OpenRouter,
/// Google AI Studio) — mesmo texto para os 3 provedores, extraído aqui para
/// não triplicar a string entre `llm_adapter.dart`, `openrouter_adapter.dart`
/// e `google_ai_studio_adapter.dart`.
library;

/// Escolhe o melhor texto disponível para enriquecer, na ordem
/// content -> summary -> title. Vários providers (Feedbin, Miniflux,
/// NewsBlur, TT-RSS, TheOldReader) preenchem `content`/`summary` com `''`
/// (não `null`) quando o artigo não tem aquele campo — um `??` simples pararia
/// no primeiro valor não-nulo (mesmo vazio) e nunca cairia no próximo campo,
/// então aqui tratamos string vazia como "ausente" também.
String resolveEnrichmentContent({
  String? content,
  String? summary,
  required String title,
}) {
  for (final candidate in [content, summary, title]) {
    if (candidate != null && candidate.isNotEmpty) return candidate;
  }
  return '';
}

String summaryPrompt(String content) =>
    '''Por favor, resuma o seguinte texto em 2-3 frases concisas e bem estruturadas.
Mantenha os pontos-chave e não adicione informações que não estejam no texto original.

Texto:
$content

Resumo:''';

String translationPrompt(String content, String targetLanguage) =>
    '''Traduza o seguinte texto para o idioma "$targetLanguage".
Preserve o sentido original e não adicione comentários fora da tradução.

Texto:
$content

Tradução:''';

String classificationPrompt(String content) =>
    '''Classifique o texto abaixo com uma ou mais categorias curtas
(ex.: tecnologia, política, esporte, economia), separadas por vírgula.
Responda apenas com as categorias, sem explicações.

Texto:
$content

Categorias:''';
