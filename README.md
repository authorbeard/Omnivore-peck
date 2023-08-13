# Omnivore

Omnivore allows users to search for food trucks in San Francisco, based on food offered or application status -- or, if you're hungry but indecisive (and/or adventurous), it'll return a random truck. It pulls data from [the city of San Francisco's public api](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/data).

It's called Omnivore-Peck (well, the repo is, anyway) because I got the idea to work with this API from [this assessment repo](https://github.com/peck/engineering-assessment).

I am going to continue building this out as a way to try out some new technologies and keep myself sharp while I'm looking for work. [The first full version will use Hotwire and Rails 7, as you can probably tell from the repo name.](https://github.com/authorbeard/Omnivore-hotwire-rails) As of right now, I plan to get it basically functional, do some refactoring, then do the whole thing again in another stack.

This one stops more or less where I would if I'd followed the Peck guidelines, linked to above, a bit more scrupulously (instead I took a bit more time; I explain why down below).

### Requirements

- Ruby 3.0.0 or higher
- Rails 7.0 or higher
- Postgres 14 or higher (used 14 b/c happened to have that installed already)

### Setup

The easiest way to set this up, after cloning the repo, is just to run `bundle exec rake setup:complete`. It wraps up the traditional `bundle install` and `bundle exec rails db:setup` steps with another step, which pulls food truck data from the SF API and seeds the database.

Alternatively, the seeding can be done on its own, after everything else has been set up, with `bundle exec rake setup:seed_trucks`.

It's necessary to seed the trucks, however, since the app does not offer a direct connection to the SF API, so the importer is the only way to get that data. 

It does take a minute to run all this. The truck import in particular could be made much more efficient, and will be, eventually. There's a ticket for that, anyway. 

You can also import the trucks via a Rails console, instead of using the rake task, if you wish. `TruckImporter.perform` will sort you right out.  


### Usage 

**Base URL**: `http://localhost:3000/api/v1/food_trucks`

This iteration of Omnivore simply offers a wrapper around the SF API, allowing users to query the trucks' menus for particular items, filter based on permit status, or see a random truck. 

Eventually, this data will be consumed by a frontend that add a few additional features, like a history of users' visits, a ratings system and some kind of recommendation algorithm based on that stuff. 

**Endpoint**: `/food_trucks`. Users have the options of including, as URL params, either `filters`, `q` (for keyword search) or both.

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

This version relies on plain-old JSON representations of `FoodTruck` objects. Serialization will be formalized in later tickets.

For this version, `response.body` will contain this, if something is found:

```
{
  "data": [
    {
      "id": 70,
      "external_location_id": "1660527",
      "applicant": "Natan's Catering",
      "facilitytype": "Truck",
      "cnn": "15019101",
      "locationdescription": "MISSION BAY BLVD SOUTH: 03RD ST \\ MISSION BAY BLVD to 04TH ST \\ MISSION BAY BLVD (501 - 599)",
      "address": "Assessors Block 8732/Lot001",
      "permit": "22MFF-00073",
      "status": "APPROVED",
      "schedule": "http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=22MFF-00073&ExportPDF=1&Filename=22MFF-00073_schedule.pdf",
      "priorpermit": "1",
      "fooditems": "Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks",
      "approved": "2022-11-18T00:00:00.000Z",
      "received": "2022-11-18T00:00:00.000Z",
      "expirationdate": "2023-11-15T00:00:00.000Z",
      "longitude": -122.39079035556641,
      "latitude": 37.77070297609754,
      "created_at": "2023-08-13T18:43:01.430Z",
      "updated_at": "2023-08-13T18:43:01.430Z"
    }
  ]
}
```

### Notes on this project

As mentioned, I spent a bit more time with it than the Peck README specifies, though I can't say how much more, because I didn't keep track. I approached this as, in Jira terms, an epic with several tickets, and I worked on those tickets here and there as my schedule permitted.

Here's some of what I was up to:

  - The SF API was totally new to me, so I took some time to familiarize myself with the data and poke around the documentation. That's how I found the JSON endpoint and that's how I found the documentation on things like `$$exclude_system_fields`, and `$where` queries and the `$select` param that `FoodTruckClient` uses to specify columns for return.
  - I also spent some time test-driving the API via Postman, which  helped me make some decisions on how to approach this by giving me a look at the actual data.
    - It also helped me figure out why `upsert_all` isn't working on this data: the SF API doesn't return a key when the value is `nil`, even if that column is specifically requested in a `$select`. That leaves some truck objects with fewer keys than others, which `upsert_all` rejects. It would really help `TruckImporter` be much more efficient, but I'll address it at some point in the future. That code is only called once at present, during setup, and won't be called very frequently thereafter. There are something around 500 records here at most, and the bulk of imports in the future will be far smaller (just recently updated items), so the performance hit isn't *that* urgent. It's probably also not that tricky to work around, but I wanted to focus on something else.
    - It took some trial and error to pick a reasonable scope for the uniqueness index on the `food_trucks` table. I originally thought `permit` would be enough, but those are issued to individuals/companies and can cover multiple trucks/carts. And the only field that seems both unique and is never `nil` (or never was when I was looking at the website) is called `objectid` in the JSON response but `locationid` on [the web GUI](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/data).
    - So I am aliasing that to `external_location_id` for clarity. `objectid` is uselessly vague and `locationid` makes it sound like it's meaningful within this system, which it isn't, yet. So at least with the alias, we know what that column is and where it came from.
  - Like with the aliasing -- and with the matter of selecting *only* the fields that correspond to `FoodTruck` attributes -- I spent some time thinking about this and experimenting with different approaches. Even if I wasn't planning on developing this project a little further for the sake of my own practice/learning, decisions made at the outset of a project can have long-lasting effects, so I try to take a bit of extra time to weigh my options. Not every decision has significant stakes, naturally. But there were enough to be made here that they piled up a bit.
    - I'm still not 100% sure I like my design of the FoodTrucks table, mainly because it's currently so tightly coupled to the API's schema. That seemed like a reasonable enough choice in this context, making it easy and quick to move forward, but kind of bugs me just in general terms. The only alternative that comes to mind right now would involve the Truck Importer knowing a lot about how TruckObjects are structured, and a lot of code mapping api responses to model attrs. But even those aren't really very significant obstacles. Anyway, there are a few different ways I could handle modeling a `FoodTruck` and then instantiating one from the API data, and I smelled a rabbit hole/yak-shave in the offing, so I went with the easy route for now.
  - The Peck README mentions testing and documentation. Both good and necessary things, and both things I'd include in some form or another anyway, but they do add time to the work.
  - I had to set up everything from scratch. Granted `rails new omnivore --api --database=postgresql` doesn't take that long to run, but there are things that need configuring even then, and there are all sorts of different ways to structure this code.
    - For starters, I didn't specify my testing framework, so I had to pull out a bunch of dirs and then set up and configure RSpec, FactoryBot, WebMock, etc.
    - And even once it's all set up, I regularly consulted other blogs, api docs, StackOverflow, etc. either trying to answer questions, see if someone else has already solved the problem at hand in a way I like, or double-check things that seem self-evident to me now but that I haven't revisited since learning them (sometimes they're just the preferences of the first tech leads I worked under; sometimes they're unique to a certain version of Rails but I didn't realize that; sometimes they're spot on, but it's good to re-examine them anyway).
  - I will likely be posting some more notes up to this project's wiki, once I've gone over them and gotten them legible.
  - until the above occurs, however, you have recourse to the following:

### Other Resources  

I tried to document as much of my decision-making process as possible, in addition to keeping notes on specific decisions. In addition to the documentation here in the README and whatever I add to this repo's wiki, here's what's out there: 

  - I'm using GH projects for the first time to organize my tickets: https://github.com/users/authorbeard/projects/1/views/1
    - The items/tickets there dealing with issues 1 through 18 pertain to this phase of the project.
  - I tend to write decent enough commit messages, which will be more verbose in this case.
  - I will collect those message and flesh them out in PR descriptions, when I do those.
  - Oh, and I'll be blogging about this: https://hamwater.wordpress.com
