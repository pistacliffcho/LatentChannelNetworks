// [[Rcpp::depends(RcppParallel)]]
#include "latChan.h"
#include "BKN_model.h"
#include "simLCN.h"


// LCN MODEL
RCPP_MODULE(LCN){
  class_<LCN>("LCN")
  .constructor<List, NumericMatrix, List>("Args: EdgeList, Initial p-mat, missingEdgeList")
  .method("em", &LCN::em)
  .method("llk", &LCN::llk)
  .method("get_pmat", &LCN::get_pmat)
  .method("set_pmat", &LCN::set_pmat)
  .method("computeTheta", &LCN::computeTheta)
  .method("expectedConnections", &LCN::expectedConnections)
  .method("expectedDegree", &LCN::expectedDegree)
  .method("edgeProb", &LCN::edgeProb)
  .method("crossEdges", &LCN::crossEdges)
  ;
}

// BKN MODEL
RCPP_MODULE(BKN){
  class_<BKN>("BKN")
  .constructor<List, NumericMatrix, List>("Args: EdgeCountList, Initial theta-mat")
  .method("llk", &BKN::llk)
  .method("one_em", &BKN::one_em)
  .method("em", &BKN::em)
  .method("get_theta", &BKN::get_theta)
  .method("set_theta", &BKN::set_theta)
  .method("expectedDegree", &BKN::expectedDegree)
  .method("node_llk", &BKN::node_llk)
  .method("meanEdges", &BKN::meanEdges)
  .method("crossEdges", &BKN::crossEdges);
}


//' Simulate Latent Channel Network
//' @param p_mat Matrix of channel usage probabilities
//' @export
// [[Rcpp::export]]
NumericMatrix simLCN(NumericMatrix p_mat);