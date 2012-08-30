var stdin = process.openStdin();

stdin.setEncoding('utf8');

var data = '';

stdin.on('data', function (chunk) {
	data += chunk;
});

stdin.on('end', function () {
	var parser = require('./sql');

	output = parser.parse(data);

	process.stdout.write(output);
});
