# Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig
    watch:
      stylus:
        files: ['src/**/*.styl']
        tasks: ['stylus']
      server:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      dist:
        files: ['public/**/*.css', 'dist/**/*.js', 'public/**/*.js']
        tasks: ['nodemon']

    clean:
      dist: ['dist']
      public: ['public/js/concrete.js', 'public/stylesheets/app.css']

    stylus:
      app:
        files:
          'public/stylesheets/app.css': 'src/views/stylesheets/app.styl'

    coffee:
      public:
        expand: true
        cwd: 'src/views/js'
        src: ['*.coffee']
        dest: 'public/js'
        ext: '.js'
        sourceMap: true
      server:
        expand: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'dist'
        ext: '.js'
        sourceMap: true

    copy:
      coffeekup:
        files: [{
          expand: true
          dot: true
          cwd: 'src/views'
          dest: 'dist/views'
          src: [
            '*.coffee'
          ]
        }]

      public:
        files: [{
          expand: true
          dot: true
          cwd: 'public'
          src: '**/*'
          dest: 'dist/public'
        }]

  grunt.registerTask 'default', [
    'clean',
    'coffee',
    'stylus',
    'copy'
  ]
