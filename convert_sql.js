var stdin = process.openStdin();

stdin.setEncoding('utf8');

stdin.on('data', function (chunk) {
	var parser = require('./sql');

	output = parser.parse(chunk);

	process.stdout.write(output);
});

/*
stdin.on('end', function () {
  process.stdout.write('end');
});
*/
