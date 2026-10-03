# Instalar CareerCoachOS

Esta guía es para alguien que nunca ha usado una terminal. Una terminal es una ventana donde
escribes un comando y presionas Enter, en lugar de hacer clic.

**Pásale esto a tu agente.** Si ya usas un agente de IA que puede ejecutar comandos, dale esta
frase y sáltate el resto:

> Clone this repository and follow `INSTALL.md` to set up CareerCoachOS for me, then stop and tell
> me to run `/onboard`.

## Lo que necesitas antes

- Una suscripción a Claude que incluya Claude Code (Pro o superior).
- Un computador. Solo necesitas un Mac si quieres el programador diario opcional.

## Pasos

1. **Instala Claude Code.** Entra a la página oficial de instalación de Claude Code,
   https://code.claude.com/docs/en/setup, y sigue los pasos para tu computador. Cuando
   termines, podrás escribir `claude` en una terminal.

2. **Descarga CareerCoachOS.** Elige una de estas dos formas.

   *Opción A, Download ZIP.* En la página del repositorio, haz clic en el botón verde **Code** y
   luego en **Download ZIP**. Abre el archivo descargado para que se descomprima en una carpeta.
   Mueve esa carpeta a un lugar que recuerdes, por ejemplo tu carpeta de Documentos, y
   cámbiale el nombre de `career-coach-os-main` a `CareerCoachOS`.

   *Opción B, git clone.* Si ya usas Git, ejecuta esto en una terminal:

   ```bash
   git clone https://github.com/enderlopez2307-dotcom/career-coach-os.git CareerCoachOS
   ```

3. **Abre una terminal en esa carpeta.**
   - En un Mac, abre la app Terminal, escribe `cd ` (con un espacio al final), arrastra la
     carpeta CareerCoachOS dentro de la ventana de Terminal y presiona Enter.
   - O escribe la ruta directamente, por ejemplo `cd ~/Documents/CareerCoachOS`.

4. **Inicia Claude Code.** Escribe esto y presiona Enter. La primera vez te pedirá iniciar sesión
   con tu cuenta de Claude.

   ```bash
   claude
   ```

5. **Haz la conversación de configuración, una sola vez.** Dentro de Claude Code, escribe esto y
   presiona Enter:

   ```
   /onboard
   ```

   Coach te hace una entrevista, una pregunta a la vez: tu trabajo actual, los cargos que
   quieres, el sueldo mínimo por debajo del cual un trabajo no vale la pena, dónde sí y dónde no
   quieres trabajar, empresas que quieres evitar, empresas que te interesan, algunos
   logros reales con números y un párrafo escrito por ti para que los borradores suenen como tú.
   Guarda cuatro archivos privados en `config/`. Responde con sinceridad. No inventa respuestas
   que tú no diste.

6. **Usa los comandos diarios.**

   ```
   /jobs-daily      busca en el mercado y deja borradores en tu cola de revisión
   /jobs-mail       revisa Gmail buscando respuestas y entrevistas (solo contigo presente)
   /whats-next      un menú ordenado con los mejores próximos pasos
   /checkin         registra lo que pasó y actualiza tu panel
   /review-queue    mira cada mensaje redactado, apruébalo o descártalo
   ```

   Antes de postular a cualquier lugar, ejecuta `/warm-path <Empresa>`. Antes de una entrevista,
   ejecuta `/jobs-prep` y luego `/mock-interview`.

## Cosas importantes

- Nunca se envía nada por ti. Los mensajes aprobados quedan esperando en los borradores de Gmail
  o en la caja de mensajes de LinkedIn. Tú presionas enviar.
- Tu búsqueda de trabajo se queda en esta carpeta. Git la ignora por defecto.
- Para usar las funciones de Gmail, conecta Gmail dentro de Claude Code cuando te lo ofrezca. Todo
  lo demás funciona sin eso.
- El programador diario es opcional y solo funciona en Mac. Lee `SECURITY.md` primero. Para
  activarlo, ejecuta `bash scripts/install-launchd.sh` dentro de la carpeta.
- Los nombres de los comandos se escriben en inglés, tal como aparecen aquí. Después de
  `/onboard`, puedes hablar con Claude en español y te responderá en español.
- Si te trabas, pregúntale a Claude Code con tus propias palabras, por ejemplo: "descargué el
  ZIP, ¿qué escribo ahora?"
