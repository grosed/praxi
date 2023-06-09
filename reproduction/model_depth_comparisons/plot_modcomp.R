## plot model comparison simulations
library(ggplot2)
library(gridExtra)

##function to put each measurement in a list (makes plots easier to produce)
getmeasdf <- function(lst){

    nrep = length(lst)

    ## esq (df)
    esq = matrix(unlist(lapply( 1:nrep, function(i){ lst[[i]]$esq } )), ncol=5, byrow=TRUE)
    esq_df <- as.data.frame( c(esq) )
    esq_df  <- cbind( esq_df, as.data.frame(rep(1:5, each=nrep) ) )
    names(esq_df) = c("response", "esq")
    esq_df$esq = as.factor( esq_df$esq )
    levels( esq_df$esq ) = c("2.5%", "25%", "50%", "75%", "97.5%")    
    
    ## ndq
    ndq = matrix(unlist(lapply( 1:nrep, function(i){ lst[[i]]$ndq } )), ncol=5, byrow=TRUE) 
    ndq_df <- as.data.frame( c(ndq) )
    ndq_df  <- cbind( ndq_df, as.data.frame(rep(1:5, each=nrep) ) )
    names(ndq_df) = c("response", "ndq")
    ndq_df$ndq = as.factor( ndq_df$ndq )
    levels( ndq_df$ndq ) = c("2.5%", "25%", "50%", "75%", "97.5%")    
    
    ## ntri
    ntri =  unlist( lapply( 1:nrep, function(i){ lst[[i]]$ntri } ) ) 
    
    ## nkstr
    nkstr = matrix(unlist(lapply( 1:nrep, function(i){ lst[[i]]$nkstr } )), ncol=2, byrow=TRUE) 
    
    ## nhyp
    nhyp = matrix(unlist(lapply( 1:nrep, function(i){ lst[[i]]$nhyp } )), ncol=3, byrow=TRUE)

    ## combine counts
    ncounts = cbind( ntri, nkstr, nhyp )
    counts_df = as.data.frame( c(ncounts) )
    counts_df  <- cbind( counts_df, as.data.frame(rep(1:6, each=nrep) ) )
    names(counts_df) = c("response", "count")
    counts_df$count = as.factor( counts_df$count )
    levels( counts_df$count ) = c("triangles", "3 stars", "4 stars", "h1", "h2", "h3")    
    
    ## modularity
    mod = matrix(unlist(lapply( 1:nrep, function(i){ unlist(lst[[i]]$mod) } )), ncol=6, byrow=TRUE)  # order is mod_wt, mod_eb, mod_le, nc_wt, nc_eb, nc_lec
    mod_df = as.data.frame( c(mod) )
    mod_df  <- cbind( mod_df, as.data.frame(rep(1:6, each=nrep) ) )
    names(mod_df) = c("response", "mod")
    mod_df$mod = as.factor( mod_df$mod )
    levels( mod_df$mod ) = c("mod wt", "mod eb", " mod le", "nc wt", "nc eb", "nc le")    

    ## edge density
    eden = matrix(unlist(lapply( 1:nrep, function(i){ lst[[i]]$edens[2:3] } )), ncol=2, byrow=TRUE) 
    eden_df <- as.data.frame( c(eden) )
    eden_df  <- cbind( eden_df, as.data.frame(rep(1:2, each=nrep) ) )
    names(eden_df) = c("response", "eden")
    eden_df$eden = as.factor( eden_df$eden )
    levels( eden_df$eden ) = c("k = 2", "k = 3")
    
    return( list(esq_df=esq_df, ndq_df=ndq_df, counts_df=counts_df, mod_df=mod_df, eden_df=eden_df) )
}

## for each model and case produce a violin plot for each measured quantity

makeplt_2cases <- function(measdfs1, measdfs2){
    ## edge size quantiles
    measdfcomb = rbind( measdfs1[[1]], measdfs2[[1]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[1]]) ), rep(2, length=nrow(measdfs2[[1]]) ) ) )
    names(measdfcomb) = c("response", "esq", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p1 = ggplot( measdfcomb, aes(x=esq, y=response,color=case))   + geom_boxplot(lwd=.8) + xlab("Percentiles") + ylab("Edge Size")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))  + scale_colour_brewer(palette="Dark2") ##+ scale_x_discrete(expand=c(0, 0)) 
       
    ## node degree quantiles
    measdfcomb = rbind( measdfs1[[2]], measdfs2[[2]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[2]]) ), rep(2, length=nrow(measdfs2[[2]]) ) ) )
    names(measdfcomb) = c("response", "ndq", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p2 = ggplot( measdfcomb, aes(x=ndq, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Percentiles") + ylab("Node Degree")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") ##+ scale_x_discrete(expand=c(0, 0)) 
    
    ## subgraph counts (subset?) [ MAKE INTO ONE PLOT! ]
    measdfcomb = rbind( measdfs1[[3]], measdfs2[[3]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[3]]) ), rep(2, length=nrow(measdfs2[[3]]) ) ) )
    names(measdfcomb) = c("response", "count", "case" )
    #measdfcomb$response = log(measdfcomb$response)
    measdfcomb$case = as.factor(measdfcomb$case)

    p3 = ggplot(measdfcomb[measdfcomb$count %in% c("3 stars", "4 stars"),], aes(x=count, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Subgraphs") + ylab("Count")  + theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") + scale_x_discrete(breaks=c("3 stars", "4 stars"), labels=c("3 strs", "4 strs"))  

    p4 = ggplot(measdfcomb[measdfcomb$count %in% c("triangles", "h1", "h2", "h3"),], aes(x=count, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Subgraphs") + ylab("Count")  + theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") + scale_x_discrete(breaks=c("triangles", "h1", "h2", "h3"), labels=c("tris", "h1", "h2", "h3"))#, expand=c(0, 0))  
    
    ## modularity
    ## also had wt and eb
    measdfcomb = rbind( measdfs1[[4]], measdfs2[[4]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[4]]) ), rep(2, length=nrow(measdfs2[[4]]) ) ) )
    names(measdfcomb) = c("response", "mod", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)

    p5 = ggplot( measdfcomb[measdfcomb$mod %in% c( " mod le"),], aes(x=mod, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Measure") + ylab("Modularity")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))+ scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0))   
    p6 = ggplot( measdfcomb[measdfcomb$mod %in% c( "nc le"),], aes(x=mod, y=response,  color=case))   + geom_boxplot(lwd=.8) + ylab("Number of Clusters") + xlab("Measure")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16), plot.margin=unit(c(5.5, 6, 5.5, 5.5), "points"), panel.background=element_blank(), axis.line=element_line(colour="black"))+ scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0))  
    ## edge density
    measdfcomb = rbind( measdfs1[[5]], measdfs2[[5]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[5]]) ), rep(2, length=nrow(measdfs2[[5]]) ) ) )
    names(measdfcomb) = c("response", "eden", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p7 = ggplot( measdfcomb, aes(x=eden, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Hyperedge order") + ylab("Density")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))  + scale_colour_brewer(palette="Dark2")# + scale_x_discrete(expand=c(0, 0))  
    
    ## combine plots
    lay <- rbind(c(3,4,4,1,1,2,2,7,5,6))
    p = grid.arrange(p1, p2, p3, p4, p5, p6, p7, layout_matrix=lay, nrow=1) 

    return(p)
}

makeplt_4cases <- function(measdfs1, measdfs2, measdfs3, measdfs4){

    ## edge size quantiles
    measdfcomb = rbind( measdfs1[[1]], measdfs2[[1]], measdfs3[[1]], measdfs4[[1]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[1]]) ), rep(2, length=nrow(measdfs2[[1]]) ), rep(3, length=nrow(measdfs3[[1]]) ) , rep(4, length=nrow(measdfs4[[1]]) )  ) )
    names(measdfcomb) = c("response", "esq", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p1 = ggplot( measdfcomb, aes(x=esq, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Percentiles") + ylab("Edge Size")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))  + scale_colour_brewer(palette="Dark2")# + scale_x_discrete(expand=c(0, 0)) 
       
    ## node degree quantiles
    measdfcomb = rbind( measdfs1[[2]], measdfs2[[2]], measdfs3[[2]], measdfs4[[2]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[2]]) ), rep(2, length=nrow(measdfs2[[2]]) ), rep(3, length=nrow(measdfs3[[2]]) ) , rep(4, length=nrow(measdfs4[[2]]) )  ) )
    names(measdfcomb) = c("response", "ndq", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p2 = ggplot( measdfcomb, aes(x=ndq, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Percentiles") + ylab("Node Degree")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2")# + scale_x_discrete(expand=c(0, 0)) 
    
    ## subgraph counts (subset?) [ MAKE INTO ONE PLOT! ]
    measdfcomb = rbind( measdfs1[[3]], measdfs2[[3]], measdfs3[[3]], measdfs4[[3]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[3]]) ), rep(2, length=nrow(measdfs2[[3]]) ), rep(3, length=nrow(measdfs3[[3]]) ) , rep(4, length=nrow(measdfs4[[3]]) )  ) )
    names(measdfcomb) = c("response", "count", "case" )
    #measdfcomb$response = log(measdfcomb$response)
    measdfcomb$case = as.factor(measdfcomb$case)

        p3 = ggplot(measdfcomb[measdfcomb$count %in% c("3 stars", "4 stars"),], aes(x=count, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Subgraphs") + ylab("Count")  + theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") + scale_x_discrete(breaks=c("3 stars", "4 stars"), labels=c("3 strs", "4 strs"))#, expand=c(0, 0))

    p4 = ggplot(measdfcomb[measdfcomb$count %in% c("triangles", "h1", "h2", "h3"),], aes(x=count, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Subgraphs") + ylab("Count")  + theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") + scale_x_discrete(breaks=c("triangles", "h1", "h2", "h3"), labels=c("tris", "h1", "h2", "h3"))#, expand=c(0, 0))

    ## modularity
    ## also had wt and eb
    measdfcomb = rbind( measdfs1[[4]], measdfs2[[4]], measdfs3[[4]], measdfs4[[4]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[4]]) ), rep(2, length=nrow(measdfs2[[4]]) ), rep(3, length=nrow(measdfs3[[4]]) ) , rep(4, length=nrow(measdfs4[[4]]) )  ) )
    names(measdfcomb) = c("response", "mod", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)

    p5 = ggplot( measdfcomb[measdfcomb$mod %in% c( " mod le"),], aes(x=mod, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Measure") + ylab("Modularity")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))+ scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0)) 
    p6 = ggplot( measdfcomb[measdfcomb$mod %in% c( "nc le"),], aes(x=mod, y=response,  color=case))   + geom_boxplot(lwd=.8) + ylab("Number of Clusters") + xlab("Measure")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16), plot.margin=unit(c(5.5, 6, 5.5, 5.5), "points"), panel.background=element_blank(), axis.line=element_line(colour="black"))+ scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0))

    ## edge density
    measdfcomb = rbind( measdfs1[[5]], measdfs2[[5]], measdfs3[[5]], measdfs4[[5]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[5]]) ), rep(2, length=nrow(measdfs2[[5]]) ), rep(3, length=nrow(measdfs3[[5]]) ) , rep(4, length=nrow(measdfs4[[5]]) )  ) )
    names(measdfcomb) = c("response", "eden", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p7 = ggplot( measdfcomb, aes(x=eden, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Hyperedge order") + ylab("Density")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))  + scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0)) 

    
    ## combine plots
    lay <- rbind(c(3,4,4,1,1,2,2,7,5,6))
    p = grid.arrange(p1, p2, p3, p4, p5, p6, p7, layout_matrix=lay, nrow=1) 

    return(p)
}

makeplt_5cases <- function(measdfs1, measdfs2, measdfs3, measdfs4, measdfs5){

    ## edge size quantiles
    measdfcomb = rbind( measdfs1[[1]], measdfs2[[1]], measdfs3[[1]], measdfs4[[1]], measdfs5[[1]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[1]]) ), rep(2, length=nrow(measdfs2[[1]]) ), rep(3, length=nrow(measdfs3[[1]]) ) , rep(4, length=nrow(measdfs4[[1]]) ), rep(5, length=nrow(measdfs5[[1]]) ) ) )
    names(measdfcomb) = c("response", "esq", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p1 = ggplot( measdfcomb, aes(x=esq, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Percentiles") + ylab("Edge Size")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))  + scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0)) 
       
    ## node degree quantiles
    measdfcomb = rbind( measdfs1[[2]], measdfs2[[2]], measdfs3[[2]], measdfs4[[2]], measdfs5[[2]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[2]]) ), rep(2, length=nrow(measdfs2[[2]]) ), rep(3, length=nrow(measdfs3[[2]]) ) , rep(4, length=nrow(measdfs4[[2]]) ),  rep(5, length=nrow(measdfs5[[2]]) ) ) )
    names(measdfcomb) = c("response", "ndq", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p2 = ggplot( measdfcomb, aes(x=ndq, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Percentiles") + ylab("Node Degree")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0)) 
    
    ## subgraph counts (subset?) [ MAKE INTO ONE PLOT! ]
    measdfcomb = rbind( measdfs1[[3]], measdfs2[[3]], measdfs3[[3]], measdfs4[[3]], measdfs5[[3]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[3]]) ), rep(2, length=nrow(measdfs2[[3]]) ), rep(3, length=nrow(measdfs3[[3]]) ) , rep(4, length=nrow(measdfs4[[3]]) ), rep(5, length=nrow(measdfs5[[3]]) )  ) )
    names(measdfcomb) = c("response", "count", "case" )
    #measdfcomb$response = log(measdfcomb$response)
    measdfcomb$case = as.factor(measdfcomb$case)

    p3 = ggplot(measdfcomb[measdfcomb$count %in% c("3 stars", "4 stars"),], aes(x=count, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Subgraphs") + ylab("Count")  + theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") + scale_x_discrete(breaks=c("3 stars", "4 stars"), labels=c("3 strs", "4 strs"), expand=c(0, 0))

    p4 = ggplot(measdfcomb[measdfcomb$count %in% c("triangles", "h1", "h2", "h3"),], aes(x=count, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Subgraphs") + ylab("Count")  + theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black")) + scale_colour_brewer(palette="Dark2") + scale_x_discrete(breaks=c("triangles", "h1", "h2", "h3"), labels=c("tris", "h1", "h2", "h3"))#, expand=c(0, 0))
    
    ## modularity
    ## also had wt and eb
    measdfcomb = rbind( measdfs1[[4]], measdfs2[[4]], measdfs3[[4]], measdfs4[[4]], measdfs5[[4]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[4]]) ), rep(2, length=nrow(measdfs2[[4]]) ), rep(3, length=nrow(measdfs3[[4]]) ) , rep(4, length=nrow(measdfs4[[4]]) ), rep(5, length=nrow(measdfs5[[4]]) )  ) )
    names(measdfcomb) = c("response", "mod", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)

    p5 = ggplot( measdfcomb[measdfcomb$mod %in% c( " mod le"),], aes(x=mod, y=response,  color=case))   + geom_boxplot(lwd=.8) + xlab("Measure") + ylab("Modularity")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))+ scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0)) 
    p6 = ggplot( measdfcomb[measdfcomb$mod %in% c( "nc le"),], aes(x=mod, y=response,  color=case))   + geom_boxplot(lwd=.8) + ylab("Number of Clusters") + xlab("Measure")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16), plot.margin=unit(c(5.5, 6, 5.5, 5.5), "points"), panel.background=element_blank(), axis.line=element_line(colour="black"))+ scale_colour_brewer(palette="Dark2")# + scale_x_discrete(expand=c(0, 0))

    ## edge density
    measdfcomb = rbind( measdfs1[[5]], measdfs2[[5]], measdfs3[[5]], measdfs4[[5]], measdfs5[[5]] )
    measdfcomb = cbind( measdfcomb, c(rep(1, length=nrow(measdfs1[[5]]) ), rep(2, length=nrow(measdfs2[[5]]) ), rep(3, length=nrow(measdfs3[[5]]) ) , rep(4, length=nrow(measdfs4[[5]]) ), rep(5, length=nrow(measdfs5[[5]]) )  ) )
    names(measdfcomb) = c("response", "eden", "case" )
    measdfcomb$case = as.factor(measdfcomb$case)
    
    p7 = ggplot( measdfcomb, aes(x=eden, y=response,  color=case))   + geom_boxplot(lwd=.8)+ xlab("Hyperedge order") + ylab("Density")+ theme(text=element_text(size=16), axis.text.x = element_text( size=16, angle=45, hjust=1), axis.text.y = element_text( size=16, angle=45), legend.position="none", panel.background=element_blank(), axis.line=element_line(colour="black"))  + scale_colour_brewer(palette="Dark2") #+ scale_x_discrete(expand=c(0, 0)) 

    
    ## combine plots
    lay <- rbind(c(3,4,4,1,1,2,2,7,5,6))
    p = grid.arrange(p1, p2, p3, p4, p5, p6, p7, layout_matrix=lay, nrow=1)

    return(p)
}

#######################################################################################################################
############################################## make plots #############################################################

load("./output/beta_out.RData")
sz=20

b1 = getmeasdf( get( paste("beta_out", 1, sep="") ) )
b2 = getmeasdf( get( paste("beta_out", 2, sep="") ) )
p=makeplt_2cases(b1, b2)
ggsave(paste("./plots/beta_violin_line.pdf",sep=""), plot=p , width=sz, height=1.5*(sz/10))
dev.off()

## murphy
load("./output/murphy_out.RData")

m1 = getmeasdf( get( paste("murphy_out", 1, sep="") ) )
m2 = getmeasdf( get( paste("murphy_out", 2, sep="") ) )
m3 = getmeasdf( get( paste("murphy_out", 3, sep="") ) )
m4 = getmeasdf( get( paste("murphy_out", 4, sep="") ) )
p=makeplt_4cases(m1, m2, m3, m4)
ggsave(paste("./plots/murphy_violin_line.pdf",sep=""), plot=p , width=sz, height=1.5*(sz/10))
dev.off()

## lsm
load("./output/lsm_out.RData")

l1 = getmeasdf( get( paste("lsm_out", 1, sep="") ) )
l2 = getmeasdf( get( paste("lsm_out", 2, sep="") ) )
l3 = getmeasdf( get( paste("lsm_out", 3, sep="") ) )
l4 = getmeasdf( get( paste("lsm_out", 4, sep="") ) )
l5 = getmeasdf( get( paste("lsm_out", 5, sep="") ) )
p=makeplt_5cases(l1, l2, l3, l4, l5)
ggsave(paste("./plots/lsm_violin_line.pdf",sep=""), plot=p , width=sz, height=1.5*(sz/10))
dev.off()
