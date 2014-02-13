TestsFinder = require '../helpers/tests_finder'


# Parses the file-related options out of the given argv,
# augments them with default values,
# represents them in a user-friendly way,
# and provides all the resulting test files to Mycha.
class FileConfiguration

  constructor: ({test_dir, default_files, files}) ->

    # The files that Mycha should provide to Mocha.
    @files = []
    @files = @files.concat default_files
    if files.length > 0
      @files = @files.concat files
    else
      @files = @files.concat new TestsFinder(test_dir).files()


  # Serializes this data into a format so that it can be given to
  # childProcess.spawn.
  to_args: ->
    @files



module.exports = FileConfiguration