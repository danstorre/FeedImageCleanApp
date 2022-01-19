[![CI](https://github.com/danstorre/cleanCodeApp/actions/workflows/CI.yml/badge.svg)](https://github.com/danstorre/cleanCodeApp/actions/workflows/CI.yml)


### Story: Customer requests to see their image feed

### Narrative #1

```
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newst feed image item of my friend
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed
```

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends
```

#### Scenearios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there's a cached version of the feed
  And the cache is less than seven days old
 When the customer requests to see the feed
 Then the app should display the latest feed saved

Given the customer doesn't have connectivity
  And there's a cached version of the feed
  And the cache is seven days old or more
 When the customer requests to see the feed
 Then the app should display an error message

Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the feed
 Then the app should display an error message
```

## Use Cases

### Load Feed from Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Feed Feed Image" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates feed images from valid data.
5. System delivers feed images.

#### Invalid data - error course (sad path):
1. System delivers invalid data error.

#### No connectivity - error course (sad path):
1. System delivers connectivity error.


### Load Feed from cache Use Case

#### Data:
- Max age (7 days)

#### Primary course:
1. Execute "Retrieve Feed Images" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
4. System creates feed images from cached data.
5. System delivers feed images.

#### Retrieval Error course (sad path):
1. System deletes cache.
2. System delivers error.

#### Expired cache course (sad path):
1. System deletes cache.
2. System delivers no feed images.

#### Empty cache course (sad path):
1. System delivers no feed images.


### Cache Feed Use Case

#### Data:
- Feed images

#### Primary course (happy path):
1. Execute "Save Feed Images" command with above data.
2. System deletes old cache data.
3. System encodes feed images.
4. System timestamps the new cache.
5. Systems saves new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.


## Model Specs

### Feed Image

| Property      | Type                |
|---------------|---------------------|
| `id`          | `UUID`              |
| `description` | `String` (optional) |
| `location`    | `String` (optional) |
| `url`          | `URL`              |


### Payload contract

```
GET *url* (TBD)
200 RESPONSE
{
  "items": [
    {
      "id": "a UUID",
      "description": "a description",
      "location": "a location",
      "image": "https://a-image.url",
    },
    {
      "id": "another UUID",
      "description": "another description",
      "image": "https://another-image.url"
    },
    {
      "id": "even another UUID",
      "location": "even another location",
      "image": "https://even-another-image.url"
    },
    {
      "id": "yet another UUID",
      "image": "https://yet-another-image.url"
    }
    ...
  ]
}
