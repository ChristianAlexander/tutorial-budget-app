# Budgie

A demonstration of a Phoenix LiveView-powered budget tracking application.

Follow the development progress in the YouTube tutorial series called [Phoenix App from Scratch](https://www.youtube.com/playlist?list=PL31bV6MaFAPllC8JP0vaRKrVm5kj7c1vc).

[![Watch the series](https://img.youtube.com/vi/0rpt5sMb7cw/maxresdefault.jpg)](https://www.youtube.com/playlist?list=PL31bV6MaFAPllC8JP0vaRKrVm5kj7c1vc)

## Prerequisites

To run this application, you need to have a PostgreSQL database running. You can use Docker to easily set up a local database instance.

```bash
docker run --name budget-app-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=budgie_dev -p 5432:5432 -d postgres
```

To start the server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Progress

- [x] Initial setup / authentication
- [x] Budget data modeling and forms
- [x] Transaction data modeling and forms
- [ ] Efficient data fetching with grouping sets
- [ ] Permissions
- [ ] Add collaboration with invitation links
- [ ] UI/UX polishing
- [ ] Landing page
