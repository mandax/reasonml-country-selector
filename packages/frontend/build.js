const { build } = require('esbuild');
const { replace } = require('esbuild-plugin-replace');

console.log(process.env.API_URL)

build({
  entryPoints: ['lib/es6/src/App.bs.js'],
  outfile: 'lib/js/app.js',
  bundle: true,
  minify: false,
  sourcemap: true,
  plugins: [
    replace({
      'API_URL': `${process.env.API_URL}`,
    })
  ]
})
  .then(() => console.log('⚡Bundle build complete ⚡'))
  .catch(() => {
    process.exit(1);
  });
