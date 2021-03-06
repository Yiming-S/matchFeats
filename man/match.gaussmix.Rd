\name{match.gaussmix}
\alias{match.gaussmix}

\title{Gaussian Mixture Approach}

\description{
This function performs maximum likelihood estimation (MLE) for the one-to-one feature matching problem represented as a multivariate Gaussian mixture model. MLE is carried out via the EM algorithm. 
}

\usage{
match.gaussmix(x, unit = NULL, mu = NULL, V = NULL, equal.variance = FALSE, 
	method = c("exact", "approx"), control = list())
}

\arguments{
\item{x}{data: matrix of dimensions \eqn{(mn,p)} or 3D array of dimensions \eqn{(p,m,n)} with \eqn{m} = number of labels/classes, \eqn{n} = number of sample units, and \eqn{p} = number of variables)}

\item{unit}{integer (=number of units) or vector mapping rows of \code{x} to sample units (length \eqn{mn}). Must be specified only if \code{x} is a matrix.}

\item{mu}{optional matrix of initial mean vectors for MLE (dimension \eqn{(p,m)})}

\item{V}{optional matrix of initial covariance matrices for MLE (dimension \eqn{(p,p,m)})}
  
\item{equal.variance}{logical: if \code{TRUE}, all covariance matrices are assumed to be equal}
  
\item{method}{method for calculating class probabilities of feature vectors}

\item{control}{optional list of tuning parameters for MLE}
}

\details{
Given a sample of \eqn{n} statistical units, each having \eqn{m} possibly mislabeled feature vectors, the one-to-one matching problem is to find a set of \eqn{n} label permutations that produce the best match of feature vectors across units. This problem is sometimes referred to as "data association ambiguity". 

The feature vectors of all units are represented as independent realizations of \eqn{m} multivariate normal distributions with unknown parameters. For each sample unit, exactly one vector from each distribution is observed and the \eqn{m} corresponding labels are randomly permuted. The goal is to estimate the true class of each feature vector, as well as the mean vector and covariance matrix of each distribution. These quantities are evaluated by ML estimation via the Expectation-Maximization (EM) algorithm. 

If \code{x} is a matrix, the rows should be sorted by increasing unit label and  \code{unit} should be a nondecreasing sequence of integers, for example \eqn{(1,...,1,2,...,2,...,n,...,n)} with each integer \eqn{1,...,n} replicated \eqn{m} times. 

The arguments \code{mu} and \code{V} should be specified only if a good guess is available for these parameters. Otherwise bad starting values may cause the EM algorithm to converge to a local maximum of the likelihood function quite far from the global maximum. 

If \code{method} is set to \code{exact} (default), the class probabilities of the feature vectors (given the data) are calculated exactly at each iteration of the EM algorithm. This operation can be slow as it involves calculating the permanent of matrices. The argument \code{method} can be set to \code{approximate} to speed up calculations, but this option is not recommended in general as the approximations used are very crude and may produce "bad" EM solutions. 

The optional argument \code{control} can be specified with these fields: 
\code{maxit}, maximum number of EM iterations (default=1e4); 
\code{eps}, relative tolerance for EM convergence (default=1e-8), 
the EM algorithm stops if the relative increase in log-likelihood between two iterations is less than this tolerance; \code{verbose}, set to TRUE to display
 algorithm progress (default=FALSE). 
}

\value{
\item{sigma}{permutations that best match feature vectors across units (\eqn{(m,n)} matrix)}
\item{P}{conditional probability that a feature vector is given its 'true' label
(\eqn{(m,n)} matrix)}
\item{mu}{MLE of true mean vectors (\eqn{(p,m)} matrix)}
\item{mu}{MLE of true covariance matrices (\eqn{(p,p,m)} array or \eqn{(p,p)}matrix if \code{equal.variance=TRUE})}
\item{loglik}{Maximum value of log-likelihood}
}

\references{
Degras and Chen (2020). One-To-One Feature Matching under Association Ambiguity. 

`McLachlan and Krishnan (2008). The EM Algorithm and Extensions. 
`}


\seealso{
\code{\link{match.bca}}, \code{\link{match.kmeans}},
\code{\link{match.template}} 
}

\examples{

}

\keyword{models}
\keyword{optimize}
\concept{EM algorithm}
