# Check out live
This project is live in [Here](http://ahrefs.afp.sh)

# Rescript Country Selector

The goal with this project is to implement country selector component in rescript, writing the bindings as we go, considering the interface:
```Rescript
<CountrySelect
  className="custom-class"
  country=Some("us")
  onChange=(country => Js.log(country))
/>
```

Here I decided to do project from scratch not using any react component that would facilitate my life too much.

## Current working keyboard navigation
- [x] `Tab` will move forward with the focused elements
- [x] `Enter` to select the current focused option
- [x] `Delete` will delete the last selected option
- [ ] (wip) _use arrow keys to move focus forwards/backwards_
- [ ] `Backspace` _move focus to search input and start deleting last string character_

# OCaml

I decided to try ocaml for the first time here implementing a simple Api server to be consumed by the frontend. The server is located in `/packages/backend` folder.

# Docker experimentation

The most recent Docker Compose release has a feature called `watch` that I tested in this project, so make sure to have the latest Docker version isntalled to run this project in development mode.


## Build

This project uses `docker` and `docker compose` to build and run

Local
```sh
docker compose build -d
```
Production
```sh
docker compose -f docker-compose.prod.yml build -d 
```

## Development
> ! Make sure to have Docker Compose version >= 2.2 
```sh 
docker compose watch
```

## Running 
Local
```sh
docker compose up -d
```
Production
```sh
docker compose -f docker-compose.prod.yml up -d 
```

# Conclusion

## Backend (OCaml)

Still not familiar with the environment. I used dune in this project but was not able to write an efficient Dockerfile for it that can leverage docker compose watch, the re-build is pretty slow in the current stage for the ocaml project.

## Frontend (rescript)

If I would start this over I would probably would try a server-side rendering slution first as the API/State sync work consumed a lot of the time I've reserved for this project. I had to rush on lots of stuff and completly neglected unit tests for this, thank god functional typed programming.

Writing my own react bindings was really educational where I could learn more about how to avoid runtime errors by just designing my types better.

The project is not concluded, next step would be to improve the keyboard control and have a better structure for the element focus manipulation.

## Docker Compose Watch

Really cool feature, here are some pros and cons:

### Pros
- No local setup, just run and start coding;
- With multi-stage build is possible to have a very decent speed for development;
- No development environment, use the same build for dev and prod environments, reducing room for enviremental errors;
- Static files can be sync without need for docker rebuild;
- Leverage docker internal network and keeps network connections for distributed system as close to production as possible while development;

### Cons
- No colors in the terminal logs 🥲;
- Dockerfile requires effort with multi-stage build to achieve a good development experience;
- Had to change some configs on vim to use standalone LSPs, thank LSPZero and Mason ❤️

