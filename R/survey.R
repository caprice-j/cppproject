
# 64-bit integer casting
# the following example was found in 3.9 of
# https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-FAQ.pdf#page=17

# install.packages("devtools")
devtools::install_github("eddelbuettel/inline")
devtools::install_github("eddelbuettel/rcpp")

BigInts <- inline::cxxfunction(signature(),
                       'std::vector<long> bigints;
                       bigints.push_back(12345678901234567LL);
                       bigints.push_back(12345678901234568LL);
                       Rprintf("Difference of %ld\\n", 12345678901234568LL - 12345678901234567LL);
                       Rprintf("Difference of %ld\\n",         bigints[1]  -  bigints[0] );
                       return wrap(bigints);', plugin="Rcpp", includes="#include <vector>")
# I had the following warning but the following codes was able to be executed
# ld: warning: directory not found for option '-L/Users/Shared/Jenkins/workspace/External-R-3.3.2/vendor/build/lib'
retval<-BigInts()
options(scipen = 100)
retval
# retval is 12345678901234568 and 12345678901234568. Not preserving the original difference of '1'
stopifnot(length(unique(retval)) == 2)

# the proposed possible solution is
# returning not by integer (32-bit) or numeric/double (53-bit mantissa, they are identical),
# but by text and re-parsed by some rules such as (say) the GNU Multiple Precision Arithmetic Library

# other references:
# Google engineer's comment on Rcpp unreliability https://www.r-bloggers.com/three-ways-to-call-cc-from-r/
#   (not only on this casting, but also on other macro-oriented processings)
#
# The Rcpp's github open issue on 64-bit integer conversion https://github.com/RcppCore/Rcpp/issues/33
#       "Distinguishing at runtime based on the values would be quite expensive."
#
#
# "Conversion from C++ to R and back is driven by the templates
# Rcpp::wrap and Rcpp::as which are highly flexible and extensible,
# as documented in the Rcpp-extending vignette."  (from https://github.com/RcppCore/Rcpp )
#   https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-extending.pdf
