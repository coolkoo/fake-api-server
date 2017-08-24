Fake API Server
===============

This is a fake API server to test CI/CD as part of my proof of concept <br>

**to make this work:**<br>
<br>
1. install mongoDB<br>
2. edit mongoserver.config to point to the right mongo instance<br>
3. mongorestore backup<br>
4. bundle exec ruby drinkserver.rb<br>

<br>
here are some of the API calls:<br>

<br>
- list drinks -> /api/v1/drinks<br>
- search by name -> /api/v1/drinks?name=XXXXX<br>
- search by price -> /api/v1/drinks?price=XXXXX<br>
- search by sku -> /api/v1/drinks?sku=XXXXX<br>
