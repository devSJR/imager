mplot <- function(im,...)
    {
        graphics::par(mar=rep(0,4),omi=rep(0,4))
        plot(im,axes=FALSE,xlim=c(1,width(im)),xaxs="i",yaxs="i",...)
    }

flattenAlpha <- function(im)
    {
        alpha <- channel(im,4)
        channels(im,1:3) %>% map( ~ alpha*. ) %>% imappend("c")
    }

##' Plot objects on image using base graphics
##'
##' This function lets you use an image as a canvas for base graphics, meaning you can use R functions like "text" and "points" to plot things on an image.
##' The function takes as argument an image and an expression, executes the expression with the image as canvas, and outputs the result as an image (of the same size).
##' 
##' @param im an image (class cimg)
##' @param expr an expression (graphics code to execute)
##' @param ... passed on to plot.cimg, to control the initial rendering of the image (for example the colorscale)
##' @return an image
##' @seealso plot, capture.plot
##' @export
##' @examples
##' b.new <- implot(boats,text(150,50,"Boats!!!",cex=3))
##' plot(b.new)
##' #Draw a line on a white background
##' bg <- imfill(150,150,val=1)
##' implot(bg,lines(c(50,50),c(50,100),col="red",lwd=4))%>%plot
##' #You can change the rendering of the initial image
##' im <- grayscale(boats)
##' draw.fun <- function() text(150,50,"Boats!!!",cex=3)
##' out <- implot(im,draw.fun(),colorscale=function(v) rgb(0,v,v),rescale=FALSE)
##' plot(out)
##' @author Simon Barthelmé
implot <- function(im,expr,...)
    {
        w <- width(im)
        h <- height(im)
        Cairo::Cairo(type="raster",width=w,height=h)
        out <- try({
            mplot(im,interp=FALSE,...)
            eval(expr,parent.frame())
            ptr <- Cairo:::.image(grDevices::dev.cur())
            b <- Cairo:::.ptr.to.raw(ptr$ref,0,ptr$width*ptr$height*4) %>% as.integer
            },TRUE)
        if (is(out,"try-error"))
            {
                grDevices::dev.off()
                stop(out)
            }
        else
            {
                grDevices::dev.off()
                
                ## ch <- c(3,2,1,0)
                ## ind <- seq_along(b)
                ## im <- map(ch, ~ b[(ind %% 4)==.]) %>% map(~ as.cimg(.,dim=c(w,h,1,1))) %>% imappend("c")
                mat <- t(matrix(b,4,length(b)/4)[c(3,2,1,4),])
                dim(mat) <- c(w,h,1,4)
                as.cimg(mat) %>% flattenAlpha 
            }
    }
