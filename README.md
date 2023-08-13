# Omnivore

Omnivore is, at present, an api that returns lists of food truck data pulled from San Francisco's public API. It allows you to filter based on permit status, search for specific foods, do both or just ask for a random truck.

It's called Omnivore-Peck (well, the repo is, anyway) because I got the idea to work with this API from [this assessment repo](https://github.com/peck/engineering-assessment).

I am going to continue building this out as a way to try out some new technologies and keep myself sharp while I'm looking for work. [The first version will use Hotwire and Rails 7, as you can probably tell from the repo name.](https://github.com/authorbeard/Omnivore-hotwire-rails) As of right now, I plan to get it basically functional, do some refactoring, then do the whole thing again in another stack.

### Requirements

- Ruby 3.0.0 or higher
- Rails 7.0 or higher
- Postgres 14 or higher (used 14 b/c happened to have that installed already)

### Setup

The easiest way to do this is just to run `bundle exec rake setup:complete`. It wraps up the traditional `bundle install` and `bundle exec rails db:setup` steps with another step, which pulls food truck data from the SF API and seeds the database. 

The seeding can be done on its own, after everything else has been set up, with `bundle exec rake setup:seed_trucks`. 

It's necessary to seed the trucks, however, since the app does not offer a direct connection to the SF API, so the importer is the only way to get that data. 

It does take a minute to run all this. The truck import in particular could be made much more efficient, and will be, eventually. There's a ticket for that, anyway. 

You can also import the trucks via a Rails console, instead of using the rake task, if you wish. `TruckImporter.perform` will sort you right out.  


### Usage 

**Base URL**: `http://localhost:3000/api/v1/food_trucks`
This iteration of Omnivore simply offers a wrapper around the SF API, allowing users to query the trucks' menus for particular items, filter based on permit status, or see a random truck. 

Eventually, this data will be consumed by a frontend that add a few additional features, like a history of users' visits, a ratings system and some kind of recommendation algorithm based on that stuff. 

**Base url**: `/food_trucks` and users have the options of including, as URL params, either `filters`, `q` (for keyword search) or both. 

When both are present, the filters and keywords are applied using `AND` statements. Support for `OR` is upcoming. Or at least there's a ticket for it. 

The one exception to the foregoing is `random`. When this is included in the filters, all other params are ignored. `FoodTruck.random` uses Postgres' `tablesample` in combination with `system`. There are shortcomings with the implementation, but this is more MVP/PoC than anything. 

So, for example, to filter on only active trucks, a user should request that filter: 

```
http://localhost:3000/api/v1/food_trucks?filters=active  
```  

or, via cURL:  

```
curl -X GET "http://localhost:3000/api/v1/food_trucks?filters=active"  
```

To submit a keyword search, say for "poke", you would use `q`:  

```
http://localhost:3000/api/v1/food_trucks?q=poke  
```  

via cURL:  

``` 
curl -X GET "http://localhost:3000/api/v1/food_trucks?q=poke"  
```  

To do both (skipping straight to cURL): 

``` 
curl -X GET "http://localhost:3000/api/v1/food_trucks?q=poke&filters=inactive"  
```

#### Available filters  

**Filter values can be combined via comma-separated string**

- `active`: status of `APPROVED` and expirationdate in the future
- `expired`: status of `EXPIRED` OR expirationdate in the past 
- `suspended`: status of `SUSPENDED` 
- `inactive`: status of anything except `APPROVED` or `APPROVED` but `expirationdate` is past (includes `REQUESTED` status) 
- `random`: uses PostgreSQL's `tablesample` in combination with `system` 
  - when `filters` param includes `random`, all further filters and all query terms are ignored and a random truck is returned
  - currently uses `system(10)` as its strategy, and is recursive: it will always return a truck. using `10` seemed, in a highly unscientific survey, to be a reasonable compromise between processing time and likelihood of an empty result 

- `q`: signifies a keyword search. comma-separated string. Only trucks with all these words in their `fooditems` are returned. 


#### API Contract  

This version relies on plain-old JSON representations of `FoodTruck` object


### Other Resources  

I tried to document as much of my decision-making process as possible, in addition to keeping notes on specific decisions. In addition to the documentation here in the README and whatever I add to this repo's wiki, here's what's out there: 

  - I'm using GH projects for the first time to organize my tickets: https://github.com/users/authorbeard/projects/1/views/1
  - I tend to write decent enough commit messages, which will be more verbose in this case.
  - I will collect those message and flesh them out in PR descriptions, when I do those.
  - Oh, and I'll be blogging about this: https://hamwater.wordpress.com
