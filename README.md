# Germinator
Rails allows incremental database migrations, but only provides a single seed file (non-incremental) that causes problems when you try to run it during each application deploy.  Germinate provides a process very similar to the Rails database migrations that allows you to ensure that a data seed only gets run once in each environment.  It also provides a way to limit which Rails environments are allowed to run particular seeds, which helps protect data in sensitive environments (e.g. Production)

# License

This Rails Gem is distributed under the MIT Open Source License.  To read more about it view the [MIT-LICENSE](https://github.com/WowzaMediaSystems/germinator/blob/master/MIT-LICENSE) file in the repository.

#### Attribution

This gem was created by:

- Jocko MacGregor
- Wowza Media Systems, Inc.

# Contents
- [Installation](#installation)
- [Upgrading from Version 1.0.x](#upgrading)
- [Working with Seeds](#working_with_seeds)
- [Germinating the Database](#germinating)
- [Shriveling the Database](#shriveling)
- [Reseeding the Database](#reseeding)
- [Manual Rake Activation](#manual_activation)
- [Migrations and Seeds](#migrations_and_seeds)

# Installation<a href="installation"></a>

To install the Germinator database table and the db/germinate directory in your Rails application:

##### 1. Add the gem to your gemfile:

```ruby
# myapplication/Gemfile
gem "germinator", github: "WowzaMediaSystems/germinator"
```

##### 2. In the terminal, make sure you're in your application directory:

```bash
$ cd /myapplication
```

##### 3. Run bundle install:

```bash
$ bundle install
```

##### 4. Execute the germinator installer:

```bash
$ rails generate install_germinator
```

You're done!!

# Upgrading from Version 1.0.x<a href="upgrading"></a>

Not that there are many out there, but users who might be upgrading from version 1.0.x should note that the original migrations table `germinator_migrations` has been renamed to `germinator_seeds`.

You do not need to do anything to handle this.  The Germinator gem will automatically detect the existance of the version 1.0.x table and migrate the content to the new table.

# Working with Seeds<a href="working_with_seeds"></a>


##### What is a Seed?

Everything in the Germinator process revolves around a Seed file.   These files are very similar to the migration files generated by Rails. By default all Seed files are located in the germinate folder in your application, located here:

```bash
myapplication/db/germinate
```

Each file in this directory has a common naming convention that combines the timestamp from the time it was created, and a name to use as a reference for "planting" a seed file.  Example:

```bash
20150217100232_example_seed.rb
```

#### Generating a new Seed File

To generate a new Seed file, in your application directory, you generate a germinator and give it a unique (not previously used) camel cased name:

```bash
$ rails generate germinator MyFirstSeed
```

#### How the Seed File is constructed

The seed file is a standard ruby class that inherits the Germinator::Seed class. If you examine a newly generated seed file, the structure will look similar to this.  I've anotated each method with comments to show how they are used:

```ruby
class MyFirstSeedSeed < Germinator::Seed

  def configure config
    # This sets the configuration for the seed to use during execution.  Here are the settings with with their
    # default values:


    # "Stop on error" determines if the germination process should stop when a seed file encounters an error during
    # execution.
    #
    # If the value is FALSE, then the germination process will record the error in the `germinator_migrations` 
    # table and continue on through the list of seed files.
    #
    # If the value is TRUE, then the germination process will stop executing the list of seed files if there is
    # an error during execution.
    config.stop_on_error = false


    # "Stop on Invalid Model" determines if the germination process should stop when a seed file fails the model 
    # validation.
    #
    # If the value is FALSE, then the germination process will record the bad model validation in the
    # `germinator_migrations` table and continue on through the list of seed files.
    #
    # If the value is TRUE, then the germination process will stop executing the list of seed files if the model
    # validation fails.
    config.stop_on_invalid_model = false


    # "Environments" identifies which environments it is safe to execute this seed file in.
    # There are 4 valid values:
    #
    # true                    -> Returning true says that this seed file can be run in any environment.
    # "development"           -> Returning a string with the name of one environment limits it execution 
    #                            to that one environment, in all other environments this file will be ignored.
    # ["development", "test"] -> Returning an array of strings limits the seed files execution to only the
    #                            environments named in the array.
    # false                   -> Return false says that this seed file is disabled and should not be executed.
    config.environments = true


    # "Valid Models" indentifies which models and/or methods need to be present to properly execute this seed file.
    # Model validation occurs in every seed file before anything is executed.  There are several valid values:
    #
    # true                          -> Returning true disables model validation, and allows the seed file to execute.
    # { :some_model_name => true }  -> Requires that the SomeModelName class exists before executing the seed.
    # { :some_model_name => [ :some_method ] }
    #                               -> Requires that the SomeModelName class exists, and that it has access to a method
    #                                  named "some_method".  some_method can be a static method, an instance method or
    #                                  the name of an ActiveRecord attribute.
    # { :some_model_name => true, some_other_model_name => [ :some_method, :some_other_method ]} 
    #                               -> Requires that the SomeModelName and SomeOtherModelName classes exist, and that 
    #                                  the SomeOtherModelName class has access to a methods named "some_method" and
    #                                  "some_other_method".  some_method and some_other_method can be a static method, 
    #                                  an instance method or the name of an ActiveRecord attribute.
    config.valid_models = true

  end

  def germinate
    # This method is executed during germinate rake task.  This method is only ever executed once.  This is modeled 
    # after the database migration "up" method.
  end

  def shrivel
    # This method is execute during the shrivel rake task.  This method is only ever executed once. This is modeled
    # after the database migration "down" method.
  end

end
```

#### Environments vs. Configure

Germinate v2.0 now uses a method called `configure` to determine how the seed file behaves.   This method replaces the previous `environments` method, and expands upon the idea of configuring the seed. 

Don't worry, this behavior is backwards compatible, by default the configure.environments value is set to the existing `envrionments` method value.  This will be removed in the future, but is simply deprecated for now.

For more details on how to use the configure method, see the example code above.

# Germinating the Database<a href="germinating"></a>

To run all of the unexecuted seed files, run the following command from the application directory:

```bash
$ rake db:germinate
```

This will compare the available seed files against the timestamps stored in the `germinator_migrations` table, and run any file that has a timestamp that hasn't been stored in the table.  Files are executed in chronological order, according to their timestamp. Once the file is run, its timestamp is stored in the table.

#### Limiting Germinate Execution

By default, all unexecuted seed files are run by the `db:germinate` task.  If you only want to run a limited number of seeds, you can pass in seed limit value to the rake task.  For instance, if you only want to run the next available seed file, you would do so like this:

```bash
$ rake db:germinate[1]
```

# Shriveling the Database<a href="shriveling"></a>

To reverse the germinate process, you run the shrivel task.  This calls the shrivel command on each previously executed Germinator seed file in reverse-chronological order. To execute the task, run the following command from the application directory:

```bash
$ rake db:shrivel
```

By default this will only shrivel by one file at a time.  Each execution removes the timestamp of the executed file from the `germinator_migrations` table.

#### Executing Shrivel Multiple Times

By default, Shrivel will only execute one file at a time.  To increase the number of files executed during the Shrivel process you can pass in a limit value:

```bash
$ rake db:shrivel[3]
```

This will execute the last three files in reverse chronological order.

#### Shriveling All Files

To shrivel the database for all executed files you can run the following command in the application directory:

```bash
$ rake db:shrivel[0]
```

# Reseeding the Database<a href="reseeding"></a>

To completely reseed the database, you can execute the reseed task like this:

```bash
$ rake db:reseed
```

This executes the shrivel command on all previously executed see files, and then follows that by executing the germinate command on all available files.

#### Limiting the Reseed 

To limit how many of the files get reseeded, you can set the limit like this:

```bash
$ rake db:reseed[3]
```

This will reseed the last three seed files.


# Manual Rake Activation<a href="manual_activation"></a>

There are two rake tasks that can be used to manually activate a Seed file's `germinate` and `shrivel` command:

#### Germinate by Name

A seed file can be manually germinated through Rake by issuing the following command:

```bash
$ rake db:germinate_by_name['seed_file_name']
```

Where `seed_file_name` is the name of the seed file minus it's time stamp.   So if you wanted to actuate this file:

```bash
20150223231929_add_sample_records_to_database.rb
```

You would call:

```bash
$ rake db:germinate_by_name['add_sample_records_to_database']
```

*NOTE: This will only execute the seed file's `germinate` command if it has not previously been executed.  If it is run, an entry will be made into the `germinator_seeds` table containing the file that was executed and the details of its execution.*

#### Shrivel by Name

A seed file can be manually shriveled through Rake by issuing the following command:

```bash
$ rake db:shrivel_by_name['seed_file_name']
```

Where `seed_file_name` is the name of the seed file minus it's time stamp.   So if you wanted to actuate this file:

```bash
20150223231929_add_sample_records_to_database.rb
```

You would call:

```bash
$ rake db:shrivel_by_name['add_sample_records_to_database']
```

*NOTE: This will only execute the seed file's `shrivel` command if the seed file has been previously been germinated.  If it is run, it's entry will be removed from the `germinator_seeds` table containing the file that was executed and the details of its execution.*


# Migrations and Seeds<a href="migrations_and_seeds"></a>

It may be useful to execute a seed file from within the context of a Migration.  For that, the Germinator module has two helper methods for executing a Seed files germinate and shrivel methods.

#### Germinating

To `germinate` a seed file you can simply execute the following command in the `up` method of a migration file like so:

```ruby
    def up
      Germinator.germinate('some_seed_file_name')
    end
```

This will search for a file with name "some_seed_file_name" (disregarding the timestamp), and execute it's germinate command.  This will only occur if the seed file has not been previously germinated.


#### Shriveling

To `shrivel` a seed file you can simply execute the following command in the `down` method of a migration file like so:

```ruby
    def down
      Germinator.shrivel('some_seed_file_name')
    end
```

This will search for a file with name "some_seed_file_name" (disregarding the timestamp), and execute it's shrivel command.  This will only occur if the seed file has been previously germinated.
