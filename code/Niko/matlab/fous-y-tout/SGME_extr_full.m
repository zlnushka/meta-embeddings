function [A,b,B0,back] = SGME_extr_full(T,F,nu,R)

    if nargin==0
        test_this();
        return;
    end

    
    
    [rdim,zdim] = size(F);
    nuprime = nu + rdim - zdim;

    TR = T*R;
    
    
    A0 = F.'*TR;
    B0 = F.'*F;
    
    
    if isreal(F)
        cholB0 = chol(B0);
        solveB = @(A) cholB0\(cholB0.'\A);
    else
        solveB = @(A) B0\A;
    end
    S = solveB(A0);
    
    den = nu + sum(TR.^2,1) - sum(A0.*S,1);
    b = nuprime ./ den;
    A = bsxfun(@times,b,A0);
    
    back = @back_this;
    
    
    function [dT,dF] = back_this(dA,db,dB0)
        
        %A = bsxfun(@times,b,A0)
        db = db + sum(dA.*A0,1);                   
        dA0 = bsxfun(@times,b,dA);                 
        
        %b = nuprime ./ den
        dden = -(db.*b)./den;                      
        
        
        %den = nu + sum(TR.^2,1) - sum(A0.*S,1) 
        dTR = bsxfun(@times,(2*dden),TR);          
        dA0 = dA0 - bsxfun(@times,dden,S);         
        dS = -bsxfun(@times,dden,A0);              
        
        
        
        %S = B0\A0
        dA0_2 = solveB(dS);
        dA0 = dA0 + dA0_2;                         
        dB0 = dB0 - dA0_2*S.';
        
        %B0 = F.'*F
        dF = F*(dB0+dB0.');  
        
        
        %A0 = F.'*TR
        dF = dF + TR*dA0.';
        dTR = dTR + F*dA0;            
        
        %TR = T*R
        dT = dTR*R.';                
        
        
        
    end
    
    

end



function test_this()

    zdim = 2;
    rdim = 5;
    n = 4;
    F = randn(rdim,zdim);
    T = randn(rdim,rdim);
    
    nu = pi;
    R = randn(rdim,n);
    
    f = @(T,F) SGME_extr_full(T,F,nu,R);
    
    testBackprop_multi(f,3,{T,F},{1,1});

end
