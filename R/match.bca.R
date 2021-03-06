match.bca <- function(x, unit = NULL, w=NULL, equal.variance=FALSE,
	method = c("cyclical","random"), control = list())
{

	## Preprocess input arguments: check dimensions, 
	## reshape and recycle as needed	
	pre <- preprocess(x,unit)
	m <- pre$m; n <- pre$n; p <- pre$p
	R <- pre$R # Cholesky decomposition of w or null
	x <- pre$x; dim(x) <- c(p,m,n)
	rm(pre)
	
	## Tuning parameters
	sigma <- matrix(1:m,m,n)
	maxit <- 1000L
	if (is.list(control)) {
		if (!is.null(control$sigma)) sigma <- control$sigma
		if (!is.null(control$maxit)) maxit <- control$maxit
	}
	method <- match.arg(method)	

	## Trivial case p == 1 
	if (p == 1) {
		dim(x) <- c(m,n)
		sigma <- apply(x,2,order)
		x <- apply(x,2,sort)
		mu <- rowMeans(x)
		V <- rowMeans(x^2) - mu^2
		cost <- n * sum(V)
		if (equal.variance) V <- rep(mean(V),m)
		return(list(sigma=sigma, cost=cost, mu=mu, V=V))
	}	
	
	## Rescale data if required
	if (!is.null(w)) {
		if (is.vector(w)) {
			x <- sqrt(w) * x
		} else {
			dim(x) <- c(p,m*n)
			x <- R %*% x
			dim(x) <- c(p,m,n)
		}
	}

	## Ensure that data are non-negative
	xmin <- min(x)
	if (xmin < 0) x <- x - xmin



	## Sweeping method
	method <- match.arg(method)			
	
	## Initialize objective	
	sumxP <- matrix(0,p,m)
	for (i in 1:n)
		sumxP <- sumxP + x[,sigma[,i],i]
	objective <- sum(sumxP^2)
		
	## Define sweeping order if method = cyclical
	if (method == "cyclical") 
		sweep <- 1:n 
	
	for (count in 1:maxit)
	{
		## Store previous objective
		objective.old <- objective
		
		## Randomize sweeping order if method = random
		if (method == "random")
			sweep <- sample(1:n)
					
		for (i in 1:n)
		{
			s <- sweep[i]
			sumxPs <- sumxP - x[,sigma[,s],s]  
			sigma[,s] <- solve_LSAP(crossprod(sumxPs,x[,,s]), 
					maximum = TRUE)
			sumxP <- sumxPs + x[,sigma[,s],s]
		}			
		
		## Periodically recalculate X1 P1 + ... + Xn Pn
		## to contain roundoff errors
		if (count %% 10 == 0) {
			sumxP <- matrix(0,p,m)
			for (i in 1:n)
				sumxP <- sumxP + x[,sigma[,i],i]
		}
	
		## Update objective 
		objective <- sum(sumxP^2)
		
		## Terminate if no improvement in objective
		if (objective <= objective.old) break
		
	}	
	
	cost <- sum(x^2) - (objective/n)

	## Sample means and covariances of matched vectors
	mu <- matrix(,p,m)
	V <- array(,c(p,p,m))
	dim(x) <- c(p,m*n)
	for (l in 1:m) {
		idx <- seq.int(0,by=m,len=n) + sigma[l,]
		mu[,l] <- rowMeans(x[,idx,drop=F])
		V[,,l] <- tcrossprod(x[,idx,drop=F])/n - 
			tcrossprod(mu[,l])	
	}	
	if (xmin < 0) mu <- mu + xmin
	if (equal.variance) V <- apply(V,1:2,mean)
 	if (!is.null(w)) {
 		if (is.vector(w)) {
 			mu <- mu / sqrt(w)
 			V <- V / w
 		} else {
 			mu <- backsolve(R,mu)
 			dim(V) <- c(p,m*p)
 			V <- t(backsolve(R,V))
 			V <- t(backsolve(R,V))
			dim(V) <- c(p,p,m)	
		}		
 	}


	return(list(sigma=sigma, cost=cost, mu=mu, V=V))
	
}
