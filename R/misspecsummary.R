
## estimate the number of clusters according to cluster gap method

get_nclst <- function( us, kmx=10, b=100 ){
    out = clusGap( us, FUN = kmeans, nstart=25, K.max=kmx, B=b)
    nclst = which(out$Tab[,3]==max(out$Tab[,3]))
    return( nclst )
}

get_ntri <- function(Gpr){

    if (length(Gpr) > 0){
        ek2mat = matrix(unlist(Gpr), ncol=2, byrow=T)
        tris = count_triangles(graph_from_edgelist( ek2mat, directed = FALSE ) )
        if (sum(tris)==0){
            ntri = 0
        } else {
            ntri = sum(tris)/3
        }
    } else {
        ntri = 0
    }
    return( ntri )
}

get_sums <- function(grph, N, outlst, rep){

    if ( length(grph$elst) > 0 ){
        
        ## calculate edge lengths
        elnth = unlist(lapply( grph$elst, length))

        ## get summaries
        outlst$DD[[rep]] = getDD_from_elist(grph$elst, N)
        outlst$ntri[[rep]] = get_ntri( grph$elst[elnth==2] )
        hypcounts = get_hypmotif_count( grph$elst )
        outlst$h1[[rep]] = hypcounts[1]
        outlst$h2[[rep]] = hypcounts[2]
        outlst$h3[[rep]] = hypcounts[3]
        outlst$ijk[[rep]] = sum( elnth==3 )
        
    } else {

        outlst$DD[[rep]] = c(1)
        outlst$ntri[[rep]] = 0
        outlst$h1[[rep]] = 0
        outlst$h2[[rep]] = 0
        outlst$h3[[rep]] = 0
        outlst$ijk[[rep]] = 0
        
    }
    outlst$nclst[[rep]] = get_nclst( grph$us )
    
    return( outlst ) 
}

sim_from_preds <- function(prmsTrc, ucase, rcase, phicase, H, N, K=3, d=2)
{
    out = list()
    nRep = dim( prmsTrc$rTrc )[2]
    
    for (rep in 1:nRep)
    {

        ## sample from posterior predictive

        ## current parameter list
        prmstmp = list(N = N, K=K, us = prmsTrc$uTrc[,,rep], mu = prmsTrc$muTrc[,rep], sigma = prmsTrc$sigTrc[,,rep], r = prmsTrc$rTrc[,rep], phi0 = prmsTrc$phi0Trc[,rep], phi1 = prmsTrc$phi1Trc[,rep] )
        ## convert to hypergraph
        htmp = genHyperG_given_prms(prmstmp, addnoise=TRUE)
 
        ## calculate summaries of the hypergraph and store in list out
        out = get_sums(htmp, N, out, rep)

        if ( rep %% 100 == 0 ){ print(paste("Finished rep = ", rep)) }
    }

    return( out )
}
