under development


# YouTube Explode Dart (Musify Fork)

Fork dos pacotes `youtube_explode_dart` e `youtube_music_explode_dart`, mantidos para o app **Musify** — um player de música streaming feito em Flutter.

&gt; ⚠️ **Este fork foi atualizado para compatibilidade com Dart 3.12+**, corrigindo conflitos entre `freezed`, `source_gen` e `analyzer 8.x`.

---

## 📦 Pacotes

Este repositório contém dois pacotes que trabalham em conjunto:

| Pacote | Função |
|--------|--------|
| [`youtube_explode_dart`](./packages/youtube_explode_dart) | Busca e extrai streams de vídeo/áudio do YouTube |
| [`youtube_music_explode_dart`](./packages/youtube_music_explode_dart) | Busca metadados de artistas, álbuns e músicas do YouTube Music |

---

## 🎵 Como funciona no app

Quando você busca uma música no app:

1. **`youtube_music_explode_dart`** busca metadados do artista/álbum no YouTube Music
2. **`youtube_explode_dart`** pega o stream de áudio do vídeo correspondente
3. O app toca o áudio


---

## 🔧 Correções aplicadas

### Problema original
O pacote original usava `freezed 2.x` e `source_gen 3.x`, que geravam código inválido no Dart 3.12+:
```dart
// Código gerado antigo (quebrava no Dart 3.12)
TResult Function(_ChannelHandle value)? _,  // ❌ parâmetro nomeado com _


Solução
Atualizado freezed para ^3.2.3
Atualizado json_serializable para ^6.9.5
Removido source_gen explícito (resolvido transitivamente)
Aplicado fix automatizado nos arquivos .freezed.dart via CI
