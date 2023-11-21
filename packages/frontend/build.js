const esbuild = require('esbuild');

esbuild
  .build({
    entryPoints: ['lib/es6/src/App.bs.js'],
    outfile: 'lib/js/app.js',
    bundle: true,
    minify: process.env.NODE_ENV == 'production',
    sourcemap: true,
    define: {
      'process.env.API_URL': `${process.env.API_URL}`,
    }
  })
  .then(() => console.log('⚡Bundle build complete ⚡'))
  .catch(() => {
    process.exit(1);
  });
