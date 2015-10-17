# Turing Machine Simulator

![Turing Machine screenshot](https://raw.githubusercontent.com/dom96/turingsim/master/screenshots/complement.png)

This is a quick and simple turing machine simulator. Inspired by my
[Universities'](http://www.qub.ac.uk/) CSC2005 Computational Theory module.
It includes transitions which I have designed as an answer to some of the
questions that were set for me in that module, it's a useful tool for
tracing a turing machine and of course verifying that the transitions are
correct.

If you want to use it yourself then you need to be add your transitions and
states ahead of compilation at the bottom of the
``turingsim.nim`` file, together with the initial tape and tape position.

You can then compile using ``nimble``: ``nimble build`` and run it
by executing ``./turingsim``.

## License

This is licensed under the MIT license.
