VictoryKit is a free and open source platform to run campaigns for social change.

![build status](https://semaphoreapp.com/api/v1/projects/bfa043263901870e821c1a460cfb2438a2bdf4c6/4199/badge.png)


## Dependencies

On a Mac, you'll want to install:

    $ brew install redis postgresql

You may already have a version of Postgres installed, in which case [you'll need to remove it](https://gist.github.com/2471603) with:

    $ brew unlink postgresql
    $ brew install postgresql

To check out the code:

    $ git clone git@github.com:victorykit/victorykit.git

To confirm you have the appropriate requirements:

    $ cd victorykit
    $ ./script/bootstrap

You may need to ensure you have qt libraries installed for webkit.  On ubuntu, you may need:

    sudo apt-get install qt5-default libqt5webkit5-dev qtdeclarative5-dev build-essential

## Setting up & starting server

Make sure gems are up to date:

    $ bundle

Make sure Postgres is running

Make sure the database exists and is migrated. Note: db:seeds is out of date.

    $ rake db:create
    $ rake db:migrate

Make sure the tests pass:

    $ rake

Make sure Redis is running

Settings.yml was discontinued.  You'll need to load the settings in it into your db.  open up consule then run the following.

    $ rails console
    > yml = YAML.load(IO.read('config/settings.yml'))
    > data_dotted_keys = Hash[  yml.map{|parent,hash| hash.map{|k,v| [[parent, k].join('.'), v] } }.flatten(1) ]
    > settings = AppSettings.instance
    > settings.data = data_dotted_keys
    > settings.save!

Run the app locally

    $ rails server

Alternatively, you can use Foreman:

    $ foreman start -f Procfile.dev -p 3000
