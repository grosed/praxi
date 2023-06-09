#####################################################################
################ functions for model depth sim ######################
#####################################################################

################# check hypergraph connectec ########################

calc_grph_from_hypergraph <- function(elst,N){
    adj = matrix(0, ncol=N, nrow=N)
    if (length(elst) > 0 ){
    for (i in 1:(N-1)){
        for (j in (i+1):N){
            conn = any(unlist(lapply(elst, function(x){ all(c(i,j) %in% x) })))
            if (conn==TRUE){
                adj[i,j]=1
                adj[j,i]=1
            }
        }
    }
    }
    grph = graph_from_adjacency_matrix( adj, mode="undirected" )
    return(grph)
}

check_connected <- function(elst, N){
    grph = calc_grph_from_hypergraph(elst,N)
    conn = is_connected(grph)
    return( conn )
}

get_largest_conn_comp <- function(H, N){
    grph = calc_grph_from_hypergraph(H$elst,N)
    comp = components(grph)
    nd_kp = which( comp$membership == which( comp$csize == max(comp$csize) )[1] )

    ## take largest connected component in hypergraph
    e_kp = unlist(lapply(H$elst, function(x){ all( x %in% nd_kp ) } ))
    Hsub = list(elst=H$elst[e_kp], us=H$us[nd_kp,] )

    ## relabel vertices
    ids = sort(unique(unlist(Hsub$elst)))
    Hsub$elst = lapply(Hsub$elst, function(x){ match(x, ids) } )
    return( Hsub )
}

################### degree distributions ############################

## function to calculate degree distribution from an edge list
## degree is the number of hyperedges a node belongs to
getDD_from_elist <- function(edges, N)
{
                                        # edges is edge list for N nodes
    
    ds = rep(0, N) # store degree of each node
    M = length(edges) # number of edges (can be 0)
    if (M !=0 )
    {
        for (n in 1:N)
        {
            ## find degree of each node
            ds[n] = sum(unlist(lapply(edges, function(x){ n %in% x } )))
        }
    }

    ## calculate proportion of nodes with each degree
    maxd = max(ds) # maximum degree observed
    dd = rep(0, maxd+1) # need to include 0 as first
    for (d in 0:maxd)
    {
        dd[d+1] = sum( ds == d ) / N
    }
    
    return(dd)
}

## find average of degree distribution 
getavDD_from_ddlist<- function(ddlst)
{
                                        # ith entry of ddlist is empirical degree distribution of ith simulated graph

    nRep = length(ddlst) # number of simulated graphs
    
    ## get max degree (need to create vectors of commmon length)
    maxd = max(apply( matrix(1:nRep), 1, function(i){length(ddlst[[i]])} )) # maximum degree across all simulations

    avDD = rep(0, maxd)
    for (rep in 1:nRep)
    {
        tmpDD = ddlst[[rep]]
        tmpl = length(tmpDD)
        avDD[1:tmpl] = avDD[1:tmpl] + tmpDD # all start from 0, just add in DD
    }

    ## divide by length 
    avDD = avDD/nRep

    return( avDD )
}

############################ manipulate edge output ##########################

## convert e list to matrix of edges
convert_list_to_mat <- function(elist, N)
{
                                        # elist is list of edges
                                        # N is number of nodes
                                        # returns matrix which has N rows and M columns
                                        # (M is number of edges)

    elength = unlist( lapply( elist, length ) ) # size of each edge (some can be 0!)
    elist = (elist)[ which(elength > 0) ] # remove empty edges
    nedge = length(elist) # number of edges
    mat = matrix(0, nrow=N, ncol=nedge)
    if (nedge > 0)
    {
        for (i in 1:nedge)
        {
            etmp = elist[[i]]
            mat[etmp,i] = 1 # populate entries
        }
    }

    return( mat )
}

## get adjacency matrix
convert_to_adj <- function(mat)
{
                                        # input edge matrix
                                        # output adj matrix
                                        # 1 indicates {i,j} share an edge (can be multiple)

    print( dim(mat) )
    if( is.vector(mat) == TRUE ){
        mat = t(as.matrix(mat, ncol=1))
    }
    nNd = dim(mat)[1]
    adj = matrix(0, nrow=nNd, ncol=nNd)
    if ( dim(mat)[2] > 0 )
    {
        prs = combn(1:nNd, 2)
        nprs = dim(prs)[2]
        for (i in 1:nprs)
        {
            prtmp = prs[,i]
            if ( dim(mat)[2] > 1 ){
                ids = colSums(mat[prtmp,])}
            else { ids = sum(mat[prtmp]) }
            if ( any( ids >= 2 ) == TRUE )
            {
                adj[ prtmp[1], prtmp[2] ] = 1
                adj[ prtmp[2], prtmp[1] ] = 1
            }
            
        }    
    }
    
    return( adj )
}

############################## other summaries ##################################

## distn of edge sizes
edge_size_quants <- function(emat)
{
                                        # quantiles of edge sizes
                                        # input is matrix of edges

    elngths = colSums( emat ) # vector of edge lengths
    qs = quantile( elngths, probs = c(.025, .25, .5, .75, .975 ) )

    return( qs )
}

## node degree sizes
node_degree_quants <- function(emat)
{
                                        # quantiles of node degrees
                                        # input is matrix of edges

    nodedeg = rowSums( emat ) # number of edges each node belongs tp
    qs = quantile( nodedeg, probs = c( .025, .25, .5, .75, .975 ) )

    return( qs )
}

## edge density
edge_density <- function(emat)
{
                                        # get density of each edge size
                                        # input is matrix of edges

    N = dim( emat )[1]
    elngths = colSums( emat ) # size of edges
    elmax = max(elngths) # maximum edge size

    edens = rep(0,  N+1 ) # then edge density is uniform in size
    for (el in 1:elmax)
    {
        edens[el] = sum(elngths==el) / choose(N,el)
    }

    return(edens)
}

################## summaries based on pairwise graphs #########################

## function convert_to_adj gives us the simplified pairwise adjacency matrix

get_pr_graph <- function(adj)
{
                                        # get simplified graph of pairwise connections

    grph = graph_from_adjacency_matrix(adj, mode="undirected")

    return(grph)
}

get_no_tris <- function(grph)
{
    notri = length(triangles(grph)) / 3
    return( notri )
}

get_no_kstrs <- function(grph)
{

    str2 = make_star(3, mode="undirected") # 2 branches
    str3 = make_star(4, mode="undirected") # 3 branches

    ## find number of 2 and 3 stars
    str2iso = subgraph_isomorphisms( str2, grph  )
    if (length( str2iso ) != 0 ){
        str2iso = matrix(unlist( str2iso ), ncol=3, byrow=TRUE)
        nstr2 = dim( unique( str2iso ) )[1]
    } else { nstr2 = 0 }
    
    str3iso = subgraph_isomorphisms( str3, grph  )
    if (length( str3iso ) != 0 ){
        str3iso = matrix(unlist( str3iso ), ncol=4, byrow=TRUE)
        nstr3 = dim( unique( str3iso ) )[1]
    } else { nstr3 = 0 }
    
    return( list( nstr2 = nstr2, nstr3 = nstr3 ) )    
}

get_clst_meas <- function(grph)
{
                                        # measure 1) global clustering coefficient
                                        # 2) quantiles is local clustering coefficient

    cc_glb= transitivity(grph, type="global") # global cc
    cc_loc = transitivity(grph, type="local", isolates="zero") # local cc
    cc_loc = quantile( cc_loc, probs=c(.025, .25, .5, .75, .975) )

    return( list( globalCC = cc_glb, localCCqs = cc_loc ) )
}

get_modularity <- function(grph)
{
                                        # modularity indicates how well a graph can be divided into distinct clusters
                                        # is lies in [-1,1] where positive indicates there is a strong community structure

    ## get community labels
    wtc = cluster_walktrap(grph)
    ebc = cluster_edge_betweenness(grph)
    lec = cluster_leading_eigen(grph)

    ## calculate modularity for each group allocation
    mod_wtc = modularity( grph, membership(wtc) )
    mod_ebc = modularity( grph, membership(ebc) )
    mod_lec = modularity( grph, membership(lec) )

    ## return output
    return(list(mod_wt = mod_wtc, mod_eb = mod_ebc, mod_le = mod_lec, nc_wt = length(wtc), nc_eb = length(ebc), nc_lec = length(lec) ))
}

############################ hypergraph motif counts ##########################

get_hypmotif_count <- function(elist)
{
                                        # function to count number of occurences of hypergraph motifs

    n1 = 0 # counter for {ijk}, {ij} edges
    n2 = 0 # counter for {ijk}, {ij}, {ik} edges
    n3 = 0 # counter for {ijk}, {ij}, {ik}, {jk} edges

    elngth = unlist( lapply( elist, length) )
    ijk_lst = elist[ elngth == 3 ] # all length 3 hyperedges
    nijk = length(ijk_lst)
    ij_lst = elist[ elngth == 2 ] # all length 2 hyperedges

    if (length( ijk_lst)==0 ){
        return( list(n1=0, n2=0, n3=0 ) )
    } else {
        
        ## need to take all pairs and check they are all present
        for (e in 1:nijk)
        {
            etmp = ijk_lst[[e]]
            prtmp = combn( etmp, 2)

            pr1 = Position( function(x) identical(x, prtmp[,1]), ij_lst, nomatch=0 ) > 0
            pr2 = Position( function(x) identical(x, prtmp[,2]), ij_lst, nomatch=0 ) > 0
            pr3 = Position( function(x) identical(x, prtmp[,3]), ij_lst, nomatch=0 ) > 0

            prsum = pr1+pr2+pr3
            
            ## update counts
            if ( prsum==1 ){
                n1 = n1+1
            } else if( prsum==2){
                n2 = n2+1
            } else if( prsum==3){
                n3 = n3+1
            }
        }

        return( list(n1=n1, n2=n2, n3=n3) )
    }
}

######################### function to call everything ######################

getsummary <- function( elst, N )
{

    ## take edgelist as input
    emat = convert_list_to_mat(elst, N ) # edge matrix

    ## calc simplified graph
    adj = convert_to_adj(emat) # simplified edge matrix
    grph = get_pr_graph( adj ) # simpified graph

    ## get just pairwise graph
    emat_ij = emat[, colSums(emat)==2 ]
    adj_ij = convert_to_adj(emat_ij)
    grph_ij = get_pr_graph( adj_ij )
    
    ## put in a catch for empty graphs
    if (dim(emat)[2]==0)
    {
        dd = c(1)
        esq = rep(0,5)
        ndq = rep(0,5)
        edens = rep(0, N+1)
        ntri = 0
        nkstr = list(nstr2=0, nstr3=0)
        nhyp = list(n1=0, n2=0, n3=0)
        clst = list( globalCC = 0, localCCqs = rep(0,5) )
        mod = list(mod_wt = NA, mod_eb = NA, mod_le = NA, nc_wt = NA, nc_eb = NA, nc_lec = NA)
    } else {
        
        ## ###### get measures ######
        
        ## degree distn
        dd = getDD_from_elist(elst, N)
        
        ## edge and degree summaries
        esq = edge_size_quants(emat)
        ndq = node_degree_quants(emat)

        ## density
        edens = edge_density(emat)

        ## subgraph counts
        if (dim(emat_ij)[2]==0){
            ntri = 0
            nkstr = list(nstr2=0, nstr3=0)
        } else {
            ntri = get_no_tris(grph_ij)
            nkstr = get_no_kstrs(grph_ij)
        }
        
        ## hypergraph motif count
        nhyp = get_hypmotif_count(elst)

        ## clustering
        clst = get_clst_meas(grph)

        ## modularity (for community structures)
        mod = get_modularity(grph)

    }
    
    ## return as a list
    return( list(dd=dd, esq=esq, ndq=ndq, edens=edens, ntri=ntri, nkstr=nkstr, nhyp=nhyp, clst=clst, mod=mod))
}

#####################################################################
#####################################################################
#####################################################################

getPrDD <- function(Gpr)
{ # distribution of pairs
    nzind = t(nzsubs(Gpr))
    if (dim(nzind)[1] == 0){
        ddist = c(1) # all nodes have degree 0
    } else {
        gPr = graph_from_edgelist( nzind, directed = FALSE )
        ddist = degree_distribution(gPr)
    }
    return( ddist )
}

getHypDD <- function(Ghyp, iNew)
{ # distribution of hyperedges
    nzind = t(nzsubs(Ghyp))
    if (dim(nzind)[1] == 0){
        ddist = c(1) # all nodes have degree 0
    } else {
        Ntmp = length(iNew) # number of nodes being considered
        degs = apply( matrix(iNew), 1, function(i){sum(nzind==i)} ) # these are the degrees
        maxdeg = max(degs)
        ddist = apply( matrix(0:maxdeg), 1, function(i){sum(degs==i)/Ntmp})# now find proportions
    }
    return( ddist )
}

getTriDD <- function(Gpr)
{ # distribution of triangles
    tris = count_triangles(graph_from_edgelist( t(nzsubs(Gpr) ), directed = FALSE ) )
    if (sum(tris)==0){
        tridst = c(1) # all nodes have degree 0
        ntri = 0
    } else {
        tridst = apply( matrix(0:max(tris)), 1, function(i){sum(tris==i)/length(tris)})
        ntri = sum(tris)/3 #all triangles counted 3 times
    }
    return( list(tridst=tridst, ntri=ntri ) )
    }

## average degree distributions for pairs and hyperedges
getavDD <- function(ddlst)
{
                                        # ddlst is list whose ith entry contains $pr, $hyp

    nRep = length(ddlst)
    
    ## get max degree (need to create vectors of commmon length)
    maxpr = max(apply( matrix(1:nRep), 1, function(i){length(ddlst[[i]]$pr)} )) # maximum length pr DD
    maxhyp = max(apply( matrix(1:nRep), 1, function(i){length(ddlst[[i]]$hyp)} )) # maximum length hyp DD

    avprDD = rep(0, maxpr)
    avhypDD = rep(0, maxhyp)
    for (rep in 1:nRep)
    {
        ## add to pairs
        tmpprDD = ddlst[[rep]]$pr
        tmpprl = length(tmpprDD)
        avprDD[1:tmpprl] = avprDD[1:tmpprl] + tmpprDD

        ## add to hypers
        tmphypDD = ddlst[[rep]]$hyp
        tmphypl = length(tmphypDD)
        avhypDD[1:tmphypl] = avhypDD[1:tmphypl] + tmphypDD
    }

    ## divide by length (want average)
    avprDD = avprDD/nRep
    avhypDD = avhypDD/nRep

    return( list(avprDD=avprDD, avhypDD=avhypDD) )
}

## get triangle counts
getTriDD_hyp<- function(Ghyp)
{ # distribution of triangles
    inds = t(nzsubs(Ghyp))
    inds = rbind( inds[,c(1,2)], inds[,c(1,3)], inds[,c(2,3)] )
    inds = unique( apply( inds, 2, sort ) )
    tris = count_triangles(graph_from_edgelist( inds , directed = FALSE )  )
    if (sum(tris)==0){
        tridst = c(1) # all nodes have degree 0
        ntri = 0
    } else {
        tridst = apply( matrix(0:max(tris)), 1, function(i){sum(tris==i)/length(tris)})
        ntri = sum(tris)/3 #all triangles counted 3 times
    }
    return( list(tridst=tridst, ntri=ntri ) )
}


## function to get the motif counts
get_motif_counts <- function( edges, Nfull )
{
    ## make a graph from k=2 edges
    elen = unlist( lapply( edges, length ) )
    ek2 = edges[ elen == 2 ]

    ## make adj mat and graph
    adj = matrix(0, ncol=Nfull, nrow=Nfull )
    if (length(ek2)>0){
        for (i in 1:length(ek2)){
            adj[ek2[[i]][1], ek2[[i]][2]]=1
            adj[ek2[[i]][2], ek2[[i]][1]]=1
        }
    }

    if (sum(adj) >0 ){
        ## count number of triangles 
        graph = graph_from_adjacency_matrix( adj, mode="undirected" )
        graph = simplify(graph)
        notri = length(triangles(graph)) / 3

        ## count number of hypergraph motifs
        nohyp = get_hypmotif_count(edges)

        ## count number of {i,j},{j,k} and {i,j},{k}
        tcens = triad_census(as.directed(graph, mode="mutual"))
        no_ij_k = tcens[3] # no. motif of type {i,j}, {k}
        no_ij_ik = tcens[11] # no. motif of type {i,j}, {i,k}
        
    } else {
        notri=0
        nohyp=list(n1=0, n2=0, n3=0)
        no_ij_k = 0
        no_ij_ik = 0
    }
    
    return( list(ntri=notri, nhyp=nohyp, nm1=no_ij_k, nm2=no_ij_ik) )
}
