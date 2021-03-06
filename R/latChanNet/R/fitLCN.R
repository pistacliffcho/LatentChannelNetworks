#' @title Prep Edgelist
#' @description Prepares edgelist for \code{makeLCN}
#' @param edgeList An nx2 matrix of undirected edge pairs
#' @param max_node Optional max node value: max(edgeList) used if null
#' @noRd
prepEdgeList = function(edgeList, max_node = NULL){
  edgeList = as.matrix(edgeList)
  if(is.null(max_node)){ max_node = max(edgeList) }
  if(ncol(edgeList) != 2){ stop("edgeList should have only two columns") }
  storage.mode(edgeList) = "integer"
  
  min_node = min(edgeList)
  if(min_node < 1) stop("Node ids must start with 1")
  # Breaking up to and from nodes 
  # Note: we are only considering undirected graphs now
  n1 = edgeList[,1]
  n2 = edgeList[,2]
  
  # Dropping circles
  drop = n1 == n2
  n1 = n1[!drop]
  n2 = n2[!drop]
  
  # Because undirected, including (n1,n2) and (n2,n1) pairs
  n1_new = c(n1, n2)
  n2_new = c(n2, n1)
  n1 = n1_new
  n2 = n2_new

  splt_edges = split(n2, n1)
  ans = rep(list(integer() ), max_node)
  for(lname in names(splt_edges) ){
    unq_edges = unique(splt_edges[[lname]])
    ind = as.integer(lname)
    ans[[ind]] = unq_edges
  }
  return(ans)
}

#' @title Make Latent Channel Network Model
#' @param edgeList A nx2 matrix of edges
#' @param nDims Number of Latent Channels
#' @param missingEdges A nx2 matrix of edges for which status in unknown
#' @param pars Initial values of parameters
#' @noRd
makeLCN = function(edgeList, 
                   nDims = 5, 
                   missingEdges = NULL, 
                   pars){
  edgeList = as.matrix(edgeList)
  max_n = max(edgeList)
  if(!is.null(missingEdges)){
    missingEdges = as.matrix(missingEdges)
    max_n = max(c(max_n, max(missingEdges) ) )
  }
  preppedEdgeList = prepEdgeList(edgeList, max_n)
  nRows = length(preppedEdgeList)
  if(is.null(missingEdges)){
    preppedMissingList = lapply(rep(0, nRows), 
                                numeric)
  }
  else{
    preppedMissingList = prepEdgeList(missingEdges, nRows)
    if(length(preppedMissingList) != length(preppedEdgeList)){
      stop("Problem: missing edges not same length as edgelist!")
    }
  }
  pmat_init = pars
  
  ans = LCN$new(preppedEdgeList, 
                pmat_init, 
                preppedMissingList)
  
  return(ans)
}

#' @title Optimization of Latent Channel Network via EM-style algorithms
#' @param LCN_mod LCN model, output from makeLCN
#' @param iters Maximum iterations
#' @param type Algorithm type. Choices are "ECM", "EM" and "ParEM"
#' @param fast_em Logical: should fast EM update be used or basic? 
#' @param tol Convergence tolerance
#' @param pTol Tolerance for skipping parameter updates
#' @details Fits a latent channel network with either an ECM algorithm 
#' (\code{type = "ECM"}), an EM algorithm (\code{type = "EM"}) or 
#' a parallel implementation of the EM algorithm (\code{type = "ParEM"}). 
#' In serial, the ECM algorithm tends to be fastest, 
#' but with at least two threads, the parallel EM algorithm 
#' is expected to be fastest. 
#' 
#' To control the number of threads used by the parallel EM algorithm, 
#' use \code{RcppParallel::setThreadOptions}.
#' @noRd
emLCN = function(LCN_mod, iters = 10000, 
                 type = "ECM",
                 fast_em = T,
                 tol = 10^-4, 
                 pTol = 10^-8){
  if(type == "ECM") int_type = 1
  else if(type == "EM") int_type = 2
  else if(type == "ParEM") int_type = 3
  else stop("type must be 'ParEM', 'EM' or 'ECM'")
  ans = LCN_mod$em(iters, int_type, tol, pTol, fast_em)
  return(ans)
}