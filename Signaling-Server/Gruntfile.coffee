module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    copy:
      javascript: files: [
        {expand: true, cwd: 'client', src: ['js/**'], dest: 'dist'}]
      stylesheets: files: [
        {expand: true, cwd: 'client', src: ['css/**'], dest: 'dist'}]
      images: files: [
        {expand: true, cwd: 'client', src: ['img/**'], dest: 'dist'}]
      robots: files: [
        {expand: true, cwd: 'client', src: [
          'robots.txt', 'img/favicon.ico'], dest: 'dist'}]
    jade:
      compile:
        options: data: {debug: true, pretty: true}
        files: [{
          expand: true
          cwd: 'client'
          src: ['**/*.jade', '!layout/**/*.jade']
          dest: 'dist'
          ext: '.html'
        }]

  grunt.registerTask 'default', "Build the hole website", [
    'copy', 'jade', 'sitemap']
  grunt.registerTask 'runserver', "Run a testgwebserver", [
    'connect:server']

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadTasks 'tasks'

