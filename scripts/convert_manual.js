const mammoth = require("mammoth");
const fs = require("fs");
const path = require("path");

const input = path.join(
  __dirname,
  "..",
  "manual",
  "Manual de uso.docx"
);

const outputDir = path.join(
  __dirname,
  "..",
  "assets",
  "help"
);

const output = path.join(
  outputDir,
  "manual.html"
);

async function convertManual() {
  fs.mkdirSync(outputDir, { recursive: true });

  const result = await mammoth.convertToHtml(
    { path: input },
    {
      convertImage: mammoth.images.imgElement(function(image) {
        return image.read("base64").then(function(data) {
          return {
            src: "data:" + image.contentType + ";base64," + data
          };
        });
      })
    }
  );

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manual de uso - Tempo Sync</title>
</head>
<body>
${result.value}
</body>
</html>
`;

  fs.writeFileSync(output, html, "utf8");

  console.log("Manual convertido correctamente.");
  console.log("Archivo:", output);

  if (result.messages.length > 0) {
    console.log("Mensajes de Mammoth:");

    result.messages.forEach(message => {
      console.log(message.message);
    });
  }
}

convertManual().catch(error => {
  console.error("Error al convertir el manual:");
  console.error(error);
  process.exit(1);
});