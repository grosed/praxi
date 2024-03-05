
#include "Rcpp.h"
using namespace Rcpp;

// [[Rcpp::plugins("cpp17")]]

#include <string>


std::string marshall_string(const std::string& X)
{
    Rcout << X << std::endl;
    std::string Y {" blady blah ..."};
    return X + Y;
}


RCPP_MODULE(marshalling) 
{
function("rcpp_marshall_string", &marshall_string);
}
