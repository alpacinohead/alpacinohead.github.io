// Import the Node Filesystem library

const fs = require("fs")

fs.writeFile("message.txt", "Hello from Node.JS", (err) => {
    if (err) throw err;
    console.log("The file has been saveds!");
});


