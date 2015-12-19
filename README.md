[![Gem Version](https://badge.fury.io/rb/pretentious.svg)](https://badge.fury.io/rb/pretentious) [![Circle CI](https://circleci.com/gh/jedld/pretentious/tree/master.svg?style=svg)](https://circleci.com/gh/jedld/pretentious/tree/master)

# Ruby::Pretentious
Do you have a pretentious boss or development lead that pushes you to embrace BDD/TDD but for reasons hate it or them? here is a gem to deal with that. Now you CAN write your code first and then GENERATE tests later!! Yes you heard that right! To repeat, this gem allows you to write your code first and then automatically generate tests using the code you've written in a straightfoward manner!

On a serious note, this gem allows you to generate tests template used for "characterization tests" much better than those generated by default for various frameworks. It is also useful for "recording" current behavior of existing components in order to prepare for refactoring. As a bonus it also exposes an Object Deconstructor which allows you, given any object, to obtain a ruby code on how it was created.

## Table of Contents
1. [Installation](#installation)
- [Usage](#usage)
  1. [Using the pretentious.yml file](#using-pretentious.yml)
  2. [Declarative generation without using example files](#declarative-generation-without-using-example-files)
  3. [Minitest](#minitest)

- [Handling complex parameters and object constructors](#handling-complex-parameters-and-object-constructors)
2. [Capturing Exceptions](#capturing-exceptions)
3. [Auto Stubbing](#auto-stubbing)
4. [Object Deconstruction Utility](#object-deconstruction-utility)
5. [Using the Object deconstructor in rails](#using-the-object-deconstructor-in-rails)
6. [Things to do after](#things-to-do-after)
7. [Limitations](#limitations)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pretentious'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install pretentious
```

## Usage
The are various ways to use the pretentious gem. First is using an example file. An example file is simply a ruby script that uses your target class in a way that you want to test. The pretentious gem will then analyze what methods are called, how it is created and generate test cases for it.

The other way is using an init file to declare which classes to test and when. This is useful if you want to document how a class is used in an existing application. This is the prefered method for characterization testing on framework like rails.

Both uses cases are discussed in the succeeding sections:

### Using an example file
First Create an example file (etc. example.rb) and define the classes that you want to test, if the class is already defined elsewhere just require them. Below is an example:

```ruby
class Fibonacci

  def fib(n)
    return 0 if (n == 0)
    return 1 if (n == 1)
    return 1 if (n == 2)
    return fib(n - 1) + fib(n - 2)
  end

  def self.say_hello
    "hello"
  end

end
```

Inside a Pretentious.spec_for(...) block. Just write boring code that instantiates an object as well as calls the methods like how you'd normally use them. Finally Specify the classes that you want to test:

```ruby
class Fibonacci
  def fib(n)
    return 0 if (n == 0)
    return 1 if (n == 1)
    return 1 if (n == 2)
    return fib(n - 1) + fib(n - 2)
  end

  def self.say_hello
    "hello"
  end
end

Pretentious.spec_for(Fibonacci) do
  instance = Fibonacci.new

  (1..10).each do |n|
    instance.fib(n)
  end

  Fibonacci.say_hello
end
```

Save your file and then switch to the terminal to invoke:

```
$ pretentious example.rb
```

This will automatically generate rspec tests for Fibonacci under /spec of the current working directory.

You can actually invoke rspec at this point, but the tests will fail. Before you do that you should edit spec/spec_helper.rb and put the necessary requires and definitions there.

For this example place the following into spec_helper.rb:

```ruby
#inside spec_helper.rb
class Fibonacci
  def fib(n)
    return 0 if (n == 0)
    return 1 if (n == 1)
    return 1 if (n == 2)
    return fib(n - 1) + fib(n - 2)
  end

  def self.say_hello
    "hello"
  end
end
```

The generated spec file should look something like this

```ruby
# This file was automatically generated by the pretentious gem
require 'spec_helper'

RSpec.describe Fibonacci do
  context 'Scenario 1' do
    before do
      @fixture = Fibonacci.new
    end

    it 'should pass current expectations' do
      n = 1
      n_1 = 2
      n_2 = 3
      n_3 = 4
      n_4 = 5
      # Fibonacci#fib when passed n = 1 should return 1
      expect(@fixture.fib(n)).to eq(n)

      # Fibonacci#fib when passed n = 2 should return 1
      expect(@fixture.fib(n_1)).to eq(n)

      # Fibonacci#fib when passed n = 3 should return 2
      expect(@fixture.fib(n_2)).to eq(n_1)

      # Fibonacci#fib when passed n = 4 should return 3
      expect(@fixture.fib(n_3)).to eq(n_2)

      # Fibonacci#fib when passed n = 5 should return 5
      expect(@fixture.fib(n_4)).to eq(n_4)
    end
  end

  it 'should pass current expectations' do
    # Fibonacci::say_hello  should return 'hello'
    expect(Fibonacci.say_hello).to eq('hello')
  end
end
```

awesome!

You can also try this out with built-in libraries like MD5 for example ...

```ruby
#example.rb

Pretentious.spec_for(Digest::MD5) do
  sample = "This is the digest"
  Digest::MD5.hexdigest(sample)
end
```

You should get something like:

```ruby
# This file was automatically generated by the pretentious gem
require 'spec_helper'

RSpec.describe Digest::MD5 do
  it 'should pass current expectations' do
    sample = 'This is the digest'
    # Digest::MD5::hexdigest when passed "This is the digest" should return '9f12248dcddeda976611d192efaaf72a'
    expect(Digest::MD5.hexdigest(sample)).to eq('9f12248dcddeda976611d192efaaf72a')
  end
end
```

Note: If your test subject is already part of a larger application and would like to capture behavior in the manner that the application uses it, please look at [Declarative Generation](#declarative-generation-without-using-example-files).

### Using pretentious.yml
If you run pretentious without passing an example file, it will look for pretentious.yml in the current location. Below is an example pretentious.yml file:

```YAML
# Sample pretentious targets file
targets:
  - class: Meme
generators:
  - rspec
  - minitest
examples:
  - sample.rb
```

It basically contains three parts, the target classes to generate test for, the generators to use (rspec/minitest) and the example files to run. Note that in this case, Pretentious.spec_for/minitest_for is not needed in the example file as the target classes are already specified in the targets section.

### Declarative generation without using example files
Instead of using Pretentious.spec_for and wrapping the target code around a block, you may declaratively define when test generation should occur beforehand. This allows you to generate tests around code blocks without modifying source codes. This is useful for testing code embedded inside frameworks like rails where your "example" is already embedded inside existing code.

For example lets say you want to generate tests for UserAuthenticaion that is used inside the login method inside the UsersController inside a Rails app. You'd simply define like below:

```ruby
# initializers/pretentious.rb

Pretentious.install_watcher # install watcher if not defined previously

if Rails.env.test? #IMPORTANT don't run this when you don't need it!
  Pretentious.on(UsersController).method_called(:login).spec_for(UserAuthentication) #RSPEC
  Pretentious.on(UsersController).method_called(:login, :logout, ...).minitest_for(UserAuthentication) #minitest
end

# spec files will be written to the project root
```

The above code is equivalent to adding a spec_for inside the target method.

Note that you must include the setup code in a place that you know runs before the target code block is run. For example, if you want to test a class that is used inside a controller in rails, it is best to put it in an initializer. It is also recommended to call Pretentious.install_watcher early on to be able to generate better fixtures.

You can pass a block for manually handling the output, for example

```ruby
# initializers/pretentious.rb
Pretentious.install_watcher # install watcher if not defined previously

if Rails.env.test? #IMPORTANT don't run this when you don't need it!
    Pretentious.on(UsersController).method_called(:login).spec_for(UserAuthentication) do |results|
      puts results[UserAuthentication][:output]
    end
end

# spec files will be written to the project root
```

or, use the FileWriter utility to write it to a file

```ruby
# initializers/pretentious.rb
Pretentious.install_watcher # install watcher if not defined previously

if Rails.env.test? #IMPORTANT don't run this when you don't need it!
    Pretentious.on(UsersController).method_called(:login).spec_for(UserAuthentication) do |results|
      file_writer = Pretentious::FileWriter.new
      file_writer.write UserAuthenticaion, results[UserAuthenticaion]
    end
end
```

IMPORTANT: If using rails or if it is part of a larger app, make sure to enable this only when you intend to generate specs! delete the initializer or comment the code out when it is not needed.

## Minitest
The minitest test framework is also supported, simply use Pretentious.minitest_for instead

```ruby
Pretentious.minitest_for(Meme) do
  meme = Meme.new
  meme.i_can_has_cheezburger?
  meme.will_it_blend?
end
```

outputs:

```ruby
# This file was automatically generated by the pretentious gem
require 'minitest_helper'
require 'minitest/autorun'

class MemeTest < Minitest::Test
end

class MemeScenario1 < MemeTest
  def setup
    @fixture = Meme.new
  end

  def test_current_expectation
    # Meme#i_can_has_cheezburger?  should return 'OHAI!'
    assert_equal 'OHAI!', @fixture.i_can_has_cheezburger?

    # Meme#will_it_blend?  should return 'YES!'
    assert_equal 'YES!', @fixture.will_it_blend?
  end
end
```

## Handling complex parameters and object constructors
No need to do anything special, just do as what you would do normally and the pretentious gem will figure it out. see below for an example:

```ruby
    class TestClass1

      def initialize(message)
        @message = message
      end

      def print_message
        puts @message
      end

      def something_is_wrong
        raise StandardError.new
      end
    end

    class TestClass2
      def initialize(message)
        @message = {message: message}
      end

      def print_message
        puts @message[:message]
      end
    end

    class TestClass3
      def initialize(testclass1, testclass2)
        @class1 = testclass1
        @class2 = testclass2
      end

      def show_messages
        @class1.print_message
        @class2.print_message
        "awesome!!!"
      end
    end
```

We then instantiate the class using all sorts of weird parameters:

```ruby
  Pretentious.spec_for(TestClass3) do
      another_object = TestClass1.new("test")
      test_class_one = TestClass1.new({hello: "world", test: another_object, arr_1: [1,2,3,4,5, another_object],
                                      sub_hash: {yes: true, obj: another_object}})
      test_class_two = TestClass2.new("This is message 2")

      class_to_test = TestClass3.new(test_class_one, test_class_two)
      class_to_test.show_messages
  end
```

Creating tests for TestClass3 should yield

```ruby
require 'spec_helper'

RSpec.describe TestClass3 do
  context 'Scenario 1' do
    before do
      another_object = TestClass1.new('test')
      b = { hello: 'world', test: another_object, arr_1: [1, 2, 3, 4, 5, another_object], sub_hash: { yes: true, obj: another_object } }
      testclass1 = TestClass1.new(b)
      testclass2 = TestClass2.new('This is message 2', nil)
      @fixture = TestClass3.new(testclass1, testclass2)
    end

    it 'should pass current expectations' do
      # TestClass3#show_messages  should return 'awesome!!!'
      expect(@fixture.show_messages).to eq('awesome!!!')
    end
  end
end
```

Note that creating another instance of TestClass3 will result in the creation of another Scenario

## Capturing Exceptions
Exceptions thrown by method calls should generate the appropriate exception test case. Just make sure that you rescue inside your example file like below:

```ruby
  begin
    test_class_one.something_is_wrong
  rescue Exception=>e
  end
```

should generate the following in rspec

```ruby
  # TestClass1#something_is_wrong when passed  should return StandardError
  expect { @fixture.something_is_wrong }.to raise_error
```

## Auto stubbing
Too lazy to generate rspec-mocks stubs? Let the Pretentious gem do it for you.

Simply call the _stub method on a class and pass the classes you want to generate stubs for when passing calling spec_for or minitest_for (see below):

```ruby
Pretentious.spec_for(TestClass._stub(ClassUsedByTestClass)) do
  instance = TestClass.new
  instance.method_that_uses_the_class_to_stub
end
```

should auto generate the stub like this:

```ruby
it 'should pass current expectations' do

  var_2181613400 = ["Hello Glorious world", "HI THERE!!!!"]

  allow_any_instance_of(ClassUsedByTestClass).to receive(:a_stubbed_method).and_return("Hello Glorious world")

  # TestClass#method_that_uses_the_class_to_stub  should return ["Hello Glorious world", "HI THERE!!!!"]
  expect( @fixture.method_that_uses_the_class_to_stub ).to eq(["Hello Glorious world", "HI THERE!!!!"])

end
```

For minitest it returns something like:

```ruby
class Scenario2 < TestTestClassForMocks
  def setup
    @fixture = TestClassForMocks.new
  end

  def test_current_expectation

    var_2174209040 = {val: 1, str: "hello world", message: "a message"}

    TestMockSubClass.stub_any_instance(:return_hash, var_2174209040) do
      #TestClassForMocks#method_with_usage3 when passed message = "a message" should return {:val=>1, :str=>"hello world", :message=>"a message"}
      assert_equal var_2174209040, @fixture.method_with_usage3("a message")

    end

  end
end
```

Note: Stubbing on minitest requires the minitest-stub_any_instance gem.

stubs that return different values every call are automatically detected an the appropriate rspec stub return is generated (similar to below):

```ruby
allow_any_instance_of(TestMockSubClass).to receive(:increment_val).and_return(2, 3, 4, 5)
```

Yes, you can pass in multiple classes to be stubbed:

```ruby
Pretentious.spec_for(TestClass._stub(ClassUsedByTestClass, AnotherClassUsedByTestClass, ....)) do
  instance = TestClass.new
  instance.method_that_uses_the_class_to_stub
end
```

Note: different return values are only supported on RSpec for now

## Object Deconstruction Utility
As Pretentious as the gem is, there are other uses other than generating tests specs. Tools are also available to deconstruct objects. Object deconstruction basically means that the components used to create and initialize an object are extracted and decomposed until only primitive types remain. The pretentious gem will also generate the necessary ruby code to create one from scratch. Below is an example:

Given an instance of an activerecord base connection for example

```ruby
ActiveRecord::Base.connection
```

running deconstruct on ActiveRecord::Base.connection

```ruby
ActiveRecord::Base.connection._deconstruct_to_ruby
```

will generate the output below:

```ruby
var_70301267513280 = #<File:0x007fe094279f80>
logger = ActiveSupport::Logger.new(var_70301267513280)
connection_options = ["localhost", "root", "password", "test_db", nil, nil, 131074]
config = {adapter: "mysql", encoding: "utf8", reconnect: false, database: "test_db", pool: 5, username: "root", password: "password", host: "localhost"}
var_70301281665660 = ActiveRecord::ConnectionAdapters::MysqlAdapter.new(connection, logger, connection_options, config)
```

Note that

```ruby
var_70301267513280 = #<File:0x007fe094279f80>
```

because the pretentious gem was not able to capture its init arguments.

## How to use
Simply call:

```
Pretentious.install_watcher
```

before all your objects are initalized. This will add the following methods to all objects:

```ruby
object._deconstruct
object._deconstruct_to_ruby
```

The _deconstruct method generates a raw deconstruction data structure used by the _deconstruct_to_ruby method.

Of course _deconstruct_to_ruby generates the ruby code necessary to create the object!

If you just want to watch certain objects, the watch method accepts a block:

```ruby
some_other_class = SomeOtherClass.new("me")
the_object = Pretentious.watch {
    MyTestClass.new("some parameter", some_other_class).new
}

the_object._deconstruct_to_ruby
```

Note that the class SomeOtherClass won't get decomposed.

## Using the Object deconstructor in rails
In your Gemfile, add the pretentious gem.

```ruby
group :test do
  gem 'pretentious'
end
```

The do a bundle

```
$ bundle
```

Note: It is advisable to add it only in the test or development group! The way it logs objects would probably prevent anything from being GC'ed.

For rails, including inside application.rb may be a good place to start:

```ruby
#application.rb
require File.expand_path('../boot', __FILE__)

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if Rails.env.test? || Rails.env.development?
  puts "watching new instances"
  Pretentious::Generator.watch_new_instances
end

module App
  class Application < Rails::Application
    # ..... stuff ......

  end
end
```

boot up the rails console and blow your mind:

```
$ rails c -e test
watching new instances
Loading test environment (Rails 4.2.4)
irb: warn: can't alias context from irb_context.
2.2.0 :001 > puts ActiveRecord::Base.connection._deconstruct_to_ruby
connection = #<Mysql:0x007fe095d785c0>
var_70301267513280 = #<File:0x007fe094279f80>
logger = ActiveSupport::Logger.new(var_70301267513280)
connection_options = ["localhost", "root", "password", "app_test", nil, nil, 131074]
config = {adapter: "mysql", encoding: "utf8", reconnect: false, database: "app_test", pool: 5, username: "root", password: "password", host: "localhost"}
var_70301281665660 = ActiveRecord::ConnectionAdapters::MysqlAdapter.new(connection, logger, connection_options, config)
 => nil
2.2.0 :004 > w = User.where(id: 1)
User Load (2.8ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = ?  [["id", 1]]
=> #<ActiveRecord::Relation []>
2.2.0 :005 > w._deconstruct_to_ruby
=> "klass = User\nvar_70301317929300 = \"users\"\ntable = Arel::Table.new(var_70301317929300, klass)\nvar_70301339518120 = User::ActiveRecord_Relation.new(klass, table)\n"
2.2.0 :006 > puts w._deconstruct_to_ruby
klass = User
var_70301317929300 = "users"
table = Arel::Table.new(var_70301317929300, klass)
var_70301339518120 = User::ActiveRecord_Relation.new(klass, table)
=> nil
2.2.0 :007 >
```

Note: There are some objects it may fail to deconstruct properly because of certain [limitations](#limitations) or it may have failed to capture object creation early enough.

## Things to do after
Since your tests are already written, and hopefully nobody notices its written by a machine, you may just leave it at that. Take note of the limitations though.

But if lest your conscience suffers, it is best to go back to the specs and refine them, add more tests and behave like a bdd'er/tdd'er.

## Limitations
Computers are bad at mind reading (for now) and they don't really know your expectation of "correctness", as such it assumes your code is correct and can only use equality based matchers. It can also only reliably match primitive data types, hashes, Procs and arrays to a degree. More complex expectations are unfortunately left for the humans to resolve. This is expected to improve in future versions of the pretentious gem.

Procs that return a constant value will be resolved properly. However variable return values are currently still not generated properly will return a stub (future versions may use sourcify to resolve Procs for ruby 1.9)

Also do note that it tries its best to determine how your fixtures are created, as well as the types of your parameters and does so by figuring out (recursively) the components that your object needs. Failure can happen during this process.

Finally, Limit this gem for test environments only.

## Bugs
This is the first iteration and a lot of broken things could happen

## Contributing
1. Fork it ([https://github.com/jedld/pretentious.git](https://github.com/jedld/pretentious.git))
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
