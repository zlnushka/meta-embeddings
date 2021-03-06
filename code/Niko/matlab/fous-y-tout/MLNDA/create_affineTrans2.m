function [f,fi,paramsz] = create_affineTrans2(dim)

    if nargout==0
        test_this();
        return;
    end

    f = @f_this; 
    
    fi = @fi_this;
    
    paramsz = dim*(dim+1);

    
    function T = f_this(P,R)
        [offset,M] = unpack(P);
        T = bsxfun(@plus,offset,M\R);
    end
    
    function [R,logdetJ,back] = fi_this(P,T)
        [offset,M] = unpack(P);
        [L,U] = lu(M);
        n = size(T,2);
        logdetJ = -n*sum(log(diag(U).^2))/2;
        Delta = bsxfun(@minus,T,offset);
        R = M*Delta;
        back = @back_this;
    

        function [dP,dT] = back_this(dR,dlogdetJ)
            dM = (-n*dlogdetJ)*(U\inv(L)).';
            dDelta = M.'*dR;
            dM = dM + dR*Delta.';
            doffset = -sum(dDelta,2);
            dP =[dM(:);doffset];
            dT = dDelta;
        end
    
    end


    function [offset,P] = unpack(P)
        P = reshape(P,dim,dim+1);
        offset = P(:,end);
        P(:,end) = [];
    end

end

function test_this()

    dim = 3;
    [f,fi,sz] = create_affineTrans2(dim);
    R = randn(dim,5);
    P = randn(sz,1);
    T = f(P,R);
    Ri = fi(P,T);
    test_inverse = max(abs(R(:)-Ri(:))),

    testBackprop_multi(fi,2,{P,T});
    
    
end

