'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),

    // grunt sas
    sass: {
      compile: {
        options: {
          style: 'expanded',
        },
        files: [
          {
            expand: true,
            cwd: 'src/scss',
            src: ['**/*.scss'],
            dest: 'src_raw/css',
            ext: '.css'
          }
        ]
      }
    },

    cssmin: {
      target: {
        files: [{
          expand: true,
          cwd: 'src_raw/css',
          src: ['*.css', '!*.min.css'],
          dest: 'lib/css',
          ext: '.min.css'
        }]
      }
    },

    // grunt coffee
    coffee: {
      compile: {
        options: {
          bare: true,
          preserve_dirs: true
        },
        expand: true,
        cwd: 'src/coffee',
        src: ['**/*.coffee'],
        dest: 'src_raw/js',
        ext: '.js'
      }
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        unused: true,
        boss: true,
        eqnull: true,
        browser: true,
        globals: {}
      }
    },
    uglify: {
        js: {
            files: [{
              expand: true,
              cwd: 'src_raw/js',
              src: '**/*.js',
              dest: 'lib/js',
              ext: '.min.js'
            }]
        }
    },
    watch: {
      html: {
        files: ['**/*.html']
      },
      scss: {
        files: 'src/scss/**/*.scss',
        tasks: ['sass']
      },
      coffee: {
        files: 'src/coffee/**/*.coffee',
        tasks: ['coffee']
      },
      cssmin: {
        files: 'src_raw/css/**/*.css',
        tasks: ['cssmin']
      },
      uglify: {
        files: 'src_raw/js/**/*.js',
        tasks: ['uglify']
      },
      options: {
        livereload: true
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task.
  grunt.registerTask('default', ['sass', 'coffee', 'cssmin', 'uglify', 'watch']);

};
