
global classmeanarray totalmeanarray GlobalBestP numFolder;
countsum=0;
percentsum=0;
FileName = 'Excel_DataABC.xls';       
totItr = 5;                               
dctSize = 50;
type = 'db4';
numFolder = 30;
perFolder = 13;

f = fspecial('gaussian',[3 3],0.3);         
f1 = fspecial('gaussian',[3 3],0.2);       
h = fspecial('laplacian',0.5);
zy = 1.0;                                  
b = zeros(numFolder,8);
storeface = cell(1,256);
for i= 1:256                               
storeface{i} = zeros(1,dctSize*dctSize);   
end     


for x2 = 1:totItr                           
fprintf(1, '\n');
disp(strcat('Iteration number:',num2str(x2))); 
ttotal = zeros(dctSize,dctSize);
k = 1;
tic;
for j = 1:numFolder
    
    b(j,:) = randperm(perFolder,8);              
    tsum = zeros(dctSize,dctSize);
        for i = 1:8                           

%    face=rgb2gray(imread(strcat('D:\HD_ABC\LFW\s',...
%    num2str(j),'\1 (',num2str(b(j,i)),').jpg')));

 face=rgb2gray(imread(strcat('D:\HD_ABC\LFW\TwinA\s',...
   num2str(j),'\',num2str(b(j,i)),'.jpg')));

   
     face = im2double(face);
     f2 = fliplr(face);
     face = (f2+face)/2;
     facetemp = face;
     face = medfilt2(face);
     
    face = imfilter(face,f,'replicate'); 
     face = imfilter(face,h,'replicate'); 
  
    face = facetemp+face;                
       face = imadjust(face,[],[],(1/zy));  
     face = imfilter(face,f1,'replicate');
  



    dctface = dct2(face);                           
    u=dctface(1:dctSize,1:dctSize);                 
    
    storeface{k} = reshape(u,1,dctSize*dctSize);    
    k = k+1;
    tsum = double(tsum)+double(u);        
   end
ttotal = double(tsum)+double(ttotal);    
avg = (tsum./8);
classmeanarray{j} = avg;                  
                                          
end

avgall = ttotal/240;                        
totalmeanarray = avgall;                  
                                         


tic;
global D n;
n = 100;                 
D = dctSize*dctSize;                   
iterations = 50;
a = 0.8;
check = zeros(1,n);
temp = zeros(D,n);
tempCheck = zeros(1,n);
limit = 10;
best = 0;
bestRoute = zeros(D,iterations);



lower = zeros(D,n);
upper = 4.*ones(D,n);
x = lower + rand(D,n).*upper;     
xprev = zeros(D,n);
vprev = zeros(D,n);
R = rand(D,n);
vel = x-xprev;
posit = R < 1./(1 + exp(-x));
fitnessx = fit(posit');

for i = 1:iterations
    
    
    xprev = x;
    phi = -a + (a+a).*rand(D,n);    
    pos = randperm(n);              
    xk = x(:,pos);                  
    v = x + phi.*(x - xk);
    
    R = rand(D,n);
    vel = v-vprev;
    posit = R < 1./(1 + exp(-v));
    fitnessv = fit(posit');
    
    
    for j = 1:n
        if(fitnessv(j) > fitnessx(j))
            x(:,j) = v(:,j);
            check(j) = 0;
        else
            check(j) = check(j) + 1;
        end
    end
    
    

    R = rand(D,n);
    vel = x-xprev;
    posit = R < 1./(1 + exp(-x));
    fitnessx = fit(posit');
    p = fitnessx./(sum(fitnessx));
    
    for j = 1:n
        
        accumulation = cumsum(p);
        r = rand() * accumulation(end);
        chosen_bee = -1;
        
       
        
        for index = 1 : length(accumulation)
            if (accumulation(index) > r)
                chosen_bee = index;
                break;
            end
        end
        choice = chosen_bee;
        temp2(:,j) = x(:,chosen_bee);
        tempCheck(j) = check(chosen_bee);
    end
    x = temp2; 
    check = tempCheck;
    
    
    for j = 1:n
        if(fitnessx(j) > best)
            bestPos = j;
            best = fitnessx(j);
        end
    end
    bestRoute(:,i) = x(:,bestPos);
    

end
R = rand(D,1);
vel = bestRoute(:,i) - bestRoute(:,i-1);
posit = R < 1./(1 + exp(-bestRoute(:,i)));
GlobalBestP = posit';
trainingTime(x2)=toc;
disp(strcat('Training Time:',num2str(trainingTime(x2))));


count = length(find(GlobalBestP));            
disp(strcat('Number of selected features:',num2str(count)));

temp3(x2)= count;

for t= 1:256
    storeface{t}= storeface{t}.*GlobalBestP;  
end                                          

tic
rec=0;                                       
tests=150;                                   
                                             
for n=1:tests                       
    c = ceil(n/5); 
    b2 = 1:perFolder;  
    b1 = setdiff(b2,b(c,:));                  
                                             
                                             
    i = mod(n,5)+(5 * (mod(n,5)==0));        
%     img = rgb2gray(imread(strcat('D:\HD_ABC\LFW\s',...
%            num2str(c),'\1 (',num2str(b1(i)),').jpg')));
img=rgb2gray(imread(strcat('D:\HD_ABC\LFW\TwinB\s',...
   num2str(c),'\',num2str(b1(i)),'.jpg')));

   
 img = im2double(img);
    
   imgtemp = img;
   i2 = fliplr(img);
   img = (i2+img)/2;
     img = medfilt2(img);
 
    img = imfilter(img,f,'replicate');
    img = imfilter(img,h,'replicate'); 
   
    img = imgtemp+img;
    
     img = imadjust(img,[],[],(1/zy));
    
     img = imfilter(img,f1,'replicate');
     
     
     
    

    
    pic=dct2(img);
    pic_dct=reshape(pic(1:dctSize,1:dctSize),1,dctSize*dctSize);

    
    
    opt=pic_dct;
    

    d=zeros(1,256);
 
             for p=1:256
                 r = storeface{p};
                 d(p) = sqrt(sum((r-opt).^2));    
             end 
             
     [val,index]=min(d);                   
                                           
     
     if((ceil(index/8))==c)                
     rec=rec+1;                              
                                           
     else
%        disp(strcat('F:\Database\ORL\s',...
%            num2str(c),'\',num2str(b1(i)),'.pgm'));

     end
end 
testTime(x2) = toc;
disp(strcat('Test Time:',num2str(testTime(x2))));
%xlswrite(FileName,count,'Target',sprintf('E%d',x2));
% End of One Train-Test iteration===================%

                                            
percent=(rec/tests)*490;
percent2 = 1-(rec/tests)*490;
disp(strcat('Similarity rate(Shared Facial Features):',num2str(percent)));
disp(strcat('Dissimilarity rate:',num2str(100 - percent)));

                                           %Write to excel file
%xlswrite(FileName,percent,'Target',sprintf('C%d',x2)); 
percentsum(x2)= percent;
percentsum1 = percentsum(x2);

end

disp(' ');  

disp(strcat('Average number of selected features:',num2str(round(sum(temp3)/max(x2)))));
%xlswrite(FileName,round(sum(temp)/max(x2)),'Target',sprintf('B%d',x2+1));

  
disp(strcat('Average Training Time:',num2str(sum(trainingTime(:))/totItr)));
%xlswrite(FileName,sum(trainingTime)/totItr,'Target',sprintf('D%d',x2+1));

  
disp(strcat('Average Similarity Rate (Shared Facial Features):',num2str(sum(percentsum)/max(x2)))); 
%xlswrite(FileName,sum(percentsum)/max(x2),'Target',sprintf('C%d',x2+1));

  
%disp(strcat('Average Dissimilarity Rate :',num2str(100 - percentsum1))); 
%xlswrite(FileName,sum(percentsum)/max(x2),'Target',sprintf('C%d',x2+1));


disp(strcat('Average Testing Time:',num2str(sum(testTime(:))/totItr)));
%xlswrite(FileName,sum(testTime)/totItr,'Target',sprintf('E%d',x2+1));