# Document AI — versión web

Asistente de documentación técnica que corre **entero en el navegador**. Eliges una
carpeta de tu disco, la aplicación indexa los PDFs que hay dentro (aplicando OCR a
los escaneados) y respondes preguntas en lenguaje natural citando **documento y
página**.

No hay servidor. No hay subida de archivos. Nada sale de tu equipo.

**[▶ Abrir la aplicación](https://USUARIO.github.io/document-ai-web/)**
*(sustituye `USUARIO` por tu usuario de GitHub tras publicar)*

---

## Qué hace

- 📂 **Carpeta completa o archivos sueltos**, con el selector nativo del sistema.
- ➕ **Varias fuentes a la vez**: combina carpetas y documentos individuales, y
  quita cualquiera de ellas sin tocar las demás.
- 🔎 **Barrido** de cada carpeta y sus subcarpetas.
- 🖼️ **OCR automático** de los PDFs escaneados y de las imágenes sueltas.
- 🧠 **Indexación** con TF-IDF sobre bigramas, insensible a acentos.
- 💬 **Chat** con citas: documento, página, método y extracto.
- 🔄 **Detección de cambios**: archivos nuevos, modificados y borrados.
- 🚫 **Sin subir nada**: los archivos se leen donde están.

Formatos: `.pdf .png .jpg .jpeg .tif .tiff .bmp .webp`

## Cómo funciona

```
Carpeta elegida ──► recorrido ──► ¿archivo nuevo o cambiado?
                                          │ sí
                                          ▼
                      PDF.js extrae el texto de cada página
                                          │
                              ¿la página trae texto?
                              no ─────────┴───────── sí
                               │                      │
                        Tesseract.js OCR              │
                               └──────────┬───────────┘
                                          ▼
                            fragmentación (~1200 car.)
                                          ▼
                              índice TF-IDF en memoria
                                    + IndexedDB
                                          ▼
                                disponible en el chat
```

| Pieza | Tecnología |
|---|---|
| Acceso a la carpeta | File System Access API |
| Texto de PDFs | PDF.js 4.7 |
| OCR | Tesseract.js 5 (WebAssembly) |
| Índice persistente | IndexedDB |
| Búsqueda | TF-IDF + coseno, implementado en el propio JS |
| Redacción (opcional) | Ollama en `localhost:11434` |

## Requisitos

**Chrome o Edge 86+** para el selector de carpeta nativo. En Firefox y Safari la
aplicación funciona en *modo compatible*: se elige la carpeta con un campo de
archivos y hay que volver a elegirla después de recargar, porque esos navegadores
todavía no implementan la File System Access API.

Nada más. No hay que instalar Python, ni Tesseract, ni compilar nada: el OCR viaja
como WebAssembly y se descarga solo la primera vez que aparece un documento
escaneado (unos 15 MB, luego queda en la caché del navegador).

## Cómo abrirla

> **No funciona con doble clic en `index.html`.** Los navegadores bloquean por
> seguridad el JavaScript de las páginas abiertas con el protocolo `file://`, así
> que la página se ve bien pero ningún botón responde. Si te pasa, la propia
> aplicación te lo explica en pantalla.

Tres formas válidas:

1. **Publicada en GitHub Pages** — la más cómoda para compartir con otros.
2. **Doble clic en [`servir.bat`](servir.bat)** (Windows). Levanta un servidor
   local en el puerto 8080 y abre el navegador solo. Requiere Python instalado.
3. **A mano**, desde una terminal en esta carpeta:
   ```bash
   python -m http.server 8080
   # y abre http://localhost:8080
   ```

Servida localmente además funciona Ollama; en GitHub Pages queda bloqueado
(ver más abajo).

## Uso

1. Abre la aplicación por cualquiera de las tres vías de arriba.
2. Pulsa **Carpeta** para vigilar un directorio entero, o **Archivos** para
   elegir documentos concretos. Autoriza el acceso de lectura.
3. Repite si quieres añadir más fuentes: se acumulan y se indexan juntas.
4. Espera al indexador. El panel muestra el archivo y la página en curso.
5. Pregunta. Cada respuesta trae sus fuentes con la página exacta.

Cada fuente se quita por separado con su papelera; solo desaparecen del índice
sus documentos. Dos archivos con el mismo nombre en fuentes distintas conviven
sin pisarse.

Añadir, cambiar o borrar archivos dentro de una carpeta vigilada se refleja en
el siguiente barrido: automático cada 60 segundos, o inmediato con **Barrer
ahora**. **Barrido completo** ignora la caché y reprocesa todo.

Las carpetas y archivos elegidos con el selector nativo **sobreviven al recargar**
la página. Si el navegador retira el permiso al cerrarlo, la fuente aparece
marcada en ámbar y basta con volver a añadirla; el índice ya construido sigue
consultable mientras tanto.

## Respuestas conversacionales (opcional)

Sin nada instalado, la aplicación responde en **modo extractivo**: te muestra los
fragmentos más relevantes con su documento y página. No redacta, pero tampoco
puede inventar: es texto literal del PDF.

Para respuestas redactadas, instala [Ollama](https://ollama.com) y descarga un modelo:

```bash
ollama pull llama3.2:3b
```

La aplicación lo detecta sola y el indicador de la cabecera pasa a verde.

> **Aviso sobre GitHub Pages y Ollama.** Una página servida por HTTPS no puede
> llamar a `http://localhost:11434`: el navegador lo bloquea como contenido mixto.
> Ollama solo funcionará si sirves esta aplicación **localmente**. Para eso, clona
> el repositorio y levanta cualquier servidor estático:
>
> ```bash
> python -m http.server 8080
> # y abre http://localhost:8080
> ```
>
> Publicada en GitHub Pages, la aplicación funciona en modo extractivo, que es
> plenamente útil para buscar y citar.

## Publicar en GitHub Pages

```bash
git init
git add .
git commit -m "Document AI - version web"
git branch -M main
git remote add origin https://github.com/USUARIO/document-ai-web.git
git push -u origin main
```

Después, en el repositorio: **Settings → Pages → Source: GitHub Actions**.

El flujo de trabajo de [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml)
publica en cada `push` a `main`. No hay compilación: se sirven los archivos tal cual.

## Estructura

```
document-ai-web/
├── index.html                     Estructura, iconos y detector de arranque
├── servir.bat                     Servidor local con un doble clic (Windows)
├── assets/
│   ├── styles.css                 Tokens de diseño, componentes, temas
│   └── app.js                     Motor completo (extracción, OCR, índice, chat)
├── .github/workflows/
│   └── deploy-pages.yml           Publicación automática
├── .nojekyll                      Evita que Jekyll procese los archivos
├── LICENSE
└── README.md
```

## Privacidad

Los documentos se leen con la File System Access API y se procesan en el propio
navegador. El texto extraído y el índice viven en IndexedDB, en tu equipo. La
aplicación solo hace peticiones de red para descargar PDF.js y Tesseract.js desde
un CDN, y — si lo tienes — a Ollama en `localhost`. **Ningún documento se envía a
ningún servidor.**

Si prefieres cero peticiones externas, descarga PDF.js y Tesseract.js y cambia las
constantes `PDFJS_URL`, `PDFJS_WORK` y `TESS_URL` al principio de
[`assets/app.js`](assets/app.js) por rutas locales.

## Diferencias con la versión de escritorio

Este repositorio es el port al navegador de una versión con backend en Python
(FastAPI + PyMuPDF + Tesseract + SQLite). Qué cambia:

| | Escritorio (Python) | Web (este repo) |
|---|---|---|
| Instalación | Python, Tesseract, dependencias | Ninguna |
| OCR | Tesseract nativo | Tesseract.js (WASM, más lento) |
| Vigilancia | `watchdog`, inmediata | Sondeo cada 60 s |
| Índice | SQLite | IndexedDB |
| Abrir el PDF citado | Sí, en la página exacta | No: el navegador no puede reabrir el archivo por ruta |
| Búsqueda semántica | TF-IDF + embeddings | TF-IDF |
| Corpus grande | Miles de documentos | Cientos (todo en memoria) |

El OCR en WebAssembly es notablemente más lento que el nativo: cuenta con varios
segundos por página escaneada. Para corpus grandes de escaneados, la versión de
escritorio rinde mucho mejor.

## Limitaciones conocidas

- El índice completo se mantiene en memoria: con miles de documentos, el navegador
  sufrirá.
- Sin `SharedArrayBuffer` (que GitHub Pages no habilita), Tesseract.js corre en un
  solo hilo.
- Los PDFs protegidos con contraseña no se procesan; aparecen marcados con error.
- El fragmento citado no enlaza al PDF original: por seguridad, el navegador no
  permite reabrir un archivo del disco por su ruta.

## Licencia

MIT — ver [LICENSE](LICENSE).

---

Creado por **Aljadis Sánchez**.
