# Instalar CareerCoachOS

Funciona donde uses Claude Code: la app de escritorio de Claude, VS Code o una terminal.

## Lo que necesitas antes

- Un plan de Claude que incluya Claude Code (Pro o superior). El plan gratis no lo incluye.
- Claude Code en cualquier app. Si todavía no tienes ninguna, lo más fácil es la **app de
  escritorio de Claude**: descárgala en https://claude.com/download, inicia sesión y abre la
  pestaña **Code**. Ya trae Claude Code incluido.

## La forma fácil: pídeselo a tu agente

**1. Pega una frase.** Abre una sesión de Claude Code en cualquier carpeta (en la app de
escritorio: pestaña Code, Local, Select folder, y elige tu carpeta de Documentos) y envía:

> Instala CareerCoachOS por mí: lee https://raw.githubusercontent.com/enderlopez2307-dotcom/career-coach-os/main/AGENT_INSTALL.md y sigue sus pasos.

El agente descarga CareerCoachOS en una carpeta nueva llamada `CareerCoachOS` dentro de tus
Documentos y te dice qué hacer después. No ejecuta ningún programa ni conecta nada.

**2. Abre una sesión nueva en esa carpeta.** Este paso es importante: los comandos de
CareerCoachOS solo aparecen en una sesión que empieza dentro de su carpeta.

- **App de escritorio de Claude:** pestaña Code, sesión nueva, Local, Select folder, elige
  `CareerCoachOS`. Si pones el modo de permisos en Accept edits, no tendrás que aprobar cada nota
  que guarda el Coach.
- **VS Code:** File, Open Folder, elige `CareerCoachOS` y abre el panel de Claude Code.
- **Terminal:** `cd ~/Documents/CareerCoachOS` en Mac, o en Windows PowerShell
  `cd (Join-Path ([Environment]::GetFolderPath('MyDocuments')) CareerCoachOS)` (así encuentra
  Documentos aunque esté dentro de OneDrive), y luego `claude`.

**3. Escribe `/onboard`.** Mira "Tu primera sesión" más abajo.

## A mano, sin agente

1. En la página del repositorio, haz clic en el botón verde **Code** y luego en **Download ZIP**.
2. Descomprímelo, cámbiale el nombre a la carpeta de `career-coach-os-main` a `CareerCoachOS` y
   muévela a tu carpeta de Documentos.
3. Abre una sesión nueva en esa carpeta, como en el paso 2 de arriba, y escribe `/onboard`.

## Tu primera sesión

`/onboard` dura unos 25 minutos, en dos partes.

**La entrevista.** `/onboard` es una conversación de verdad. El Coach te entrevista, una pregunta a la vez: tu
trabajo actual, los cargos que quieres, el sueldo mínimo por debajo del cual un trabajo no vale la
pena, dónde sí y dónde no quieres trabajar, empresas que quieres evitar, empresas que te
interesan, algunos logros reales con números y un párrafo escrito por ti para que los borradores
suenen como tú. Guarda cuatro archivos privados en `config/`. Responde con sinceridad. No inventa
respuestas que tú no diste. Puedes escribir en español; los comandos se escriben en inglés.

**La configuración.** No te vayas después de las preguntas: esta parte es la que hace que funcione.
El Coach hace una primera búsqueda en tus empresas, arma tu panel **Search Desk** y lo abre en tu
navegador (guárdalo en favoritos), te ofrece activar la búsqueda diaria de cada mañana (Mac o
Windows), revisa si Gmail está conectado y te da un recorrido de dos minutos. Si tienes que irte a
la mitad, la próxima sesión retoma donde quedaste.

Después, solo abre una sesión en la carpeta: te dirá qué sigue. Los comandos de todos los días:

```
/whats-next      un menú ordenado con los mejores próximos pasos
/jobs-daily      busca en el mercado y deja borradores en tu cola de revisión
/jobs-mail       revisa Gmail buscando respuestas y entrevistas (solo contigo presente)
/checkin         registra lo que pasó y actualiza tu panel
/review-queue    mira cada mensaje redactado, apruébalo o descártalo
```

Antes de postular a cualquier lugar, ejecuta `/warm-path <Empresa>`. Antes de una entrevista,
ejecuta `/jobs-prep` y luego `/mock-interview`.

## Cosas importantes

- Nunca se envía nada por ti. Los mensajes aprobados quedan esperando en los borradores de Gmail o
  en la caja de mensajes de LinkedIn. Tú presionas enviar.
- Tu búsqueda de trabajo se queda en esta carpeta. Git la ignora por defecto.
- Para usar `/jobs-mail`, conecta Gmail en los conectores de tu app de Claude. Todo lo demás
  funciona sin eso.
- La búsqueda diaria de cada mañana es opcional y funciona en Mac y Windows. `/onboard` te ofrece
  activarla; lee `SECURITY.md` si quieres saber exactamente qué puede y qué no puede hacer.
- En Windows, instala también Git for Windows (https://git-scm.com/downloads/win). Claude Code lo
  recomienda, y el aviso que abre cada sesión lo necesita.
- Si te trabas, pregúntale a Claude con tus propias palabras, por ejemplo: "ya descargué la
  carpeta, ¿qué hago ahora?"
