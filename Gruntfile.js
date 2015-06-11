module.exports = function(grunt) {
  grunt.initConfig({
    coffee: {
      compile: {
        files: {
			'lib/server.js': 'src/server.coffee'
      }
    }}
  });
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.registerTask('default', 'coffee');
};
