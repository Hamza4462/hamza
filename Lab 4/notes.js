const fs = require('fs');

const command = process.argv[2];
const fileName = process.argv[3];
const content = process.argv[4];

if (command === 'create') {
    if (fs.existsSync(fileName)) {
        console.log('File already exists');
    } else {
        fs.writeFileSync(fileName, content || '');
        console.log('Note created');
    }
} else if (command === 'view') {
    if (fs.existsSync(fileName)) {
        const data = fs.readFileSync(fileName, 'utf8');
        console.log(data);
    } else {
        console.log('File does not exist');
    }
} else if (command === 'append') {
    if (fs.existsSync(fileName)) {
        fs.appendFileSync(fileName, '\n' + (content || ''));
        console.log('Note updated');
    } else {
        console.log('File does not exist');
    }
} else if (command === 'delete') {
    if (fs.existsSync(fileName)) {
        fs.unlinkSync(fileName);
        console.log('Note deleted');
    } else {
        console.log('File does not exist');
    }
} else {
    console.log('Invalid command');
}