## `FIND-POLY: Fast point(s)-in-polygon(s) queries in MATLAB`

A fast "point(s)-in-polygon(s)" routine for <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a>.

Given a collection of polygons and a set of query points, `FINDPOLY` determines the set of enclosing polygons for each point. Arbitrary collections of polygons and query points are supported, and general non-convex and multiply-connected inputs can be handled. `FINDPOLY` employs various spatial indexing + sorting techniques, and is reasonably fast for large problems.

<p align="center">
  <img src="../master/test-data/img/us-county-sign.jpg" width="900px">
</p>

Given `K` polygons (each with `M` edges on average) the task is to find the enclosing polygons for a set of `N` query points. The (obvious) naive implementation is expensive, leading to `O(K*M*N)` complexity (based on a simple loop over all polygons, and calling a standard points-in-polygon test for each individually). This code aims to do better:

* Employing a "fast" <a href="https://github.com/dengwirda/inpoly">inpolygon routine</a>, reducing the complexity of each point(s)-in-polygon test (based on spatial  sorting) to approximately `O((N+M)*log(N))`.

* Employing a <a href="https://github.com/dengwirda/aabb-tree">spatial tree</a> (an `aabb-tree`) to localise each points-in-polygon query within a spatially local "tile". This typically gains another logarithmic factor, so is a big win for large `K`.

### `Quickstart`

After downloading and unzipping the current <a href="https://github.com/dengwirda/findpoly/archive/master.zip">repository</a>, navigate to the installation directory within <a href="http://www.mathworks.com">`MATLAB`</a> / <a href="https://www.gnu.org/software/octave">`OCTAVE`</a> and run the examples in `polydemo.m`.

For good performance in `OCTAVE`, the underlying `INPOLY` kernel can be compiled from `C++` as an `*.oct` file. See documentation on `MKOCTFILE` for additional information. Typically, `MATLAB`'s in-built `JIT`-acceleration leads to good performance by default.

### `License Terms`

This program may be freely redistributed under the condition that the copyright notices (including this entire header) are not removed, and no compensation is received through use of the software.  Private, research, and institutional use is free.  You may distribute modified versions of this code `UNDER THE CONDITION THAT THIS CODE AND ANY MODIFICATIONS MADE TO IT IN THE SAME FILE REMAIN UNDER COPYRIGHT OF THE ORIGINAL AUTHOR, BOTH SOURCE AND OBJECT CODE ARE MADE FREELY AVAILABLE WITHOUT CHARGE, AND CLEAR NOTICE IS GIVEN OF THE MODIFICATIONS`. Distribution of this code as part of a commercial system is permissible `ONLY BY DIRECT ARRANGEMENT WITH THE AUTHOR`. (If you are not directly supplying this code to a customer, and you are instead telling them how they can obtain it for free, then you are not required to make any arrangement with me.) 

`DISCLAIMER`:  Neither I nor the University of Sydney warrant this code in any way whatsoever. This code is provided "as-is" to be used at your own risk.

