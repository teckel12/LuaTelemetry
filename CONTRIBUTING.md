# How to contribute to Lua Telemetry

I'm really glad you're reading this, because I need volunteer developers to help this project come to fruition.

## Submitting changes

Please send a [GitHub Pull Request to Lua Telemetry](https://github.com/iNavFlight/LuaTelemetry/pull/new/master) with a clear list of what you've done (read more about [pull requests](https://help.github.com/articles/about-pull-requests/)). Please follow the coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

  $ git commit -m "A brief summary of the commit
  >
  > A paragraph describing what changed and its impact."

## Coding conventions

Start reading the Lua Telemetry code and you'll get the hang of it:

* We indent using tabs because using spaces is prone to alignment errors, restricts personal preference, takes longer and is just plain wrong.
* We always put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`) and around operators (`x += 1`, not `x+=1`).
* This is open source software. Consider the people who will read your code, and make it look nice for them. It's sort of like driving a car: Perhaps you love doing donuts when you're alone, but with passengers the goal is to make the ride as smooth as possible.
* While code readability is important, script execution speed and memory usage are also a major concern.  Sometimes, writing less-readable code is desirable due to execution speed or memory usage constraints.

## Testing

Please be sure to test your changes before creating a pull request. While your changes will be tested by others, it's appreciated when changes work on the first try.

Thanks,

[Tim Eckel](https://github.com/teckel12), Señor Lua Telemetry Coder
