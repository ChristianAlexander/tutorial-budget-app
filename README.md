# Budgie

A demonstration of a Phoenix LiveView-powered budget tracking application.

Follow the development progress in the YouTube tutorial series called [Phoenix App from Scratch](https://www.youtube.com/playlist?list=PL31bV6MaFAPllC8JP0vaRKrVm5kj7c1vc).

[![Watch the series](https://img.youtube.com/vi/0rpt5sMb7cw/maxresdefault.jpg)](https://www.youtube.com/playlist?list=PL31bV6MaFAPllC8JP0vaRKrVm5kj7c1vc)

To start the server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Docker
To start the server:

 * `docker-compose up --build`

To run the tests:

 * `docker-compose -f docker-compose-test.yml run test`

To run an iex:

 * `docker-compose run --rm web iex -S mix`

## Progress

- [x] Initial setup / authentication
- [x] Budget data modeling and forms
- [ ] Transaction data modeling and forms
- [ ] Efficient data fetching with grouping sets
- [ ] Permissions
- [ ] Add collaboration with invitation links
- [ ] UI/UX polishing
- [ ] Landing page
