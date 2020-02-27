'''
HEVC intra-prediction
--DC mode(Mode 0)
--Planar mode(Mode 1) 
--33 angular modes(Mode 2-34) 
'''
# import sys
import numpy as np

class Augmenter(object):
    def __init__(self,left_ref,top_ref,original_pu,block_size = 8,bit_depth=8,):
        self.block_size = block_size
        self.bit_depth = bit_depth
        self.left_ref = left_ref#left reference array
        self.top_ref = top_ref#top reference array
        self.original_pu = original_pu# original prediction unit
        self.pred_out = np.zeros((self.block_size,self.block_size)) #prediction output
        self.mode_mse = 0
    def interpolation(self):
        #interpolate current context to fill in the missing samples
        self.top_ref = np.insert(self.top_ref,self.block_size+1,[0 for i in range(self.block_size)])
        self.left_ref = np.insert(self.left_ref,self.block_size,[0 for i in range(self.block_size)])
        try:
            if(sum(self.top_ref)==0 and sum(self.left_ref)==0):#missing the entire context? #fill all the reference values with a nominal average given the bit depth
                self.top_ref[:] = (2**self.bit_depth-1)/2
                self.left_ref[:] = (2**self.bit_depth-1)/2
            if(self.top_ref[0]==0):# when the top left context is missing
               self.top_ref[0] =  self.left_ref[0]         
            if(np.all(self.top_ref[self.block_size+1:2*self.block_size])==0):#when the top right context is missing
                self.top_ref[self.block_size+1:2*self.block_size+1] = self.top_ref[self.block_size]
            if(np.all(self.left_ref[self.block_size:2*self.block_size-1])==0):#when the bottom left context is missing
                self.left_ref[self.block_size:2*self.block_size]= self.left_ref[self.block_size-1]
            return self.left_ref,self.top_ref
        except TypeError:
            print('Invalid reference samples: Interpolation not possible')
            return self.left_ref,self.top_ref
        except Exception:
            print('Something went wrong with the reference sample handling. Check your input variables')

    def filter_reference_array(self): 
            '''
                Reference array is filtered if the target PB is >= 32
                filter kernel = [1, 2, 1]/4
            '''
            try:
                self.top_ref = np.append(self.top_ref,0)  
                #filter top left context
                self.top_ref[0] = (self.left_ref[0]+2*self.top_ref[0]+self.top_ref[1])/4
                #filter everything else
                for i in range(1,len(self.top_ref)-1):
                    self.top_ref[i] = int((self.top_ref[i-1]+2*self.top_ref[i]+self.top_ref[i+1])/4)
                #reverse the order of left reference to allow bottom-up filtering
                self.left_ref = np.flip(self.left_ref,0)
                self.left_ref  = np.append(self.left_ref,0)#add zero paddings to both arrays
                for j in range(1,len(self.left_ref)-1):
                    self.left_ref[j] = int((self.left_ref[j-1]+2*self.left_ref[j]+self.left_ref[j+1])/4)
            except Exception as e:
                print('Error during the sample filtering: {}'.format(e))
            else:
                self.top_ref = self.top_ref[0:len(self.top_ref)-1]
                self.left_ref = np.flip(self.left_ref[0:len(self.left_ref)-1],0)
                return self.left_ref,self.top_ref
    '''
    Performance metrics
    -psnr and mse
    -TODO- R(D) performace of each mode?
    -Cost optimization to find the best mode on the fly
    '''
    def mse(self):
        self.mode_mse = np.sum((self.original_pu.astype("float") - self.pred_out.astype("float")) ** 2)
        self.mode_mse /= float(self.original_pu.shape[0] * self.block_size)
    def rd_cost(self):
        gamma = 0.1
        rate = 1000
        self.mse()
        cost = self.mode_mse + (gamma * rate)
        return cost

    def prediction(self,mode):
        '''
            This is the actual predictor
        '''
        #filter for block sizes>32 after interpolation/provides a smother gradient at the edge of the PU
        if(self.block_size>=32):
            self.interpolation() 
            self.filter_reference_array()   
        else:
            self.interpolation() 
        if(mode==0):
            pred_out= self.intra_prediction_dc()
        elif(mode==1):
            pred_out= self.intra_prediction_planar()
        else:
            pred_out = self.intra_prediction_angular(mode)
        return pred_out
    '''
    The actual mode predictors
    -DC
    -Planar
    -Angular
    '''
    #DC prediction(mode 0)
    def intra_prediction_dc(self): #dc predictions(Mode 0)
        '''
        Generates an DC prediction from the reference context
        '''
        try:
            dc_val  = (1/(2*self.block_size))*(sum(self.top_ref[1:self.block_size])+sum(self.left_ref[0:self.block_size])+self.block_size )
            self.pred_out[:] = int(dc_val) #cast to integer
        except ValueError:
            print('Invalid values for DC prediction')
        except Exception as err:
            print('Error in the DC prediction: {}'.format(err))
        else:
            return self.pred_out
    
    def intra_prediction_planar(self):#planar prediction(Mode 1)
        '''
        Generates an planar prediction from the reference context
        '''
        #initialize the interpolators
        try:
            h_values = np.zeros((self.block_size,self.block_size))
            v_values = np.zeros((self.block_size,self.block_size))
            # planar_pred = np.zeros((self.block_size,self.block_size))
            for x in range(self.block_size):   #create the vertical projection
                for y in range(self.block_size):
                    v_values[x,y] = (self.block_size-1-y)*self.top_ref[x+1] + (y+1)*self.left_ref[self.block_size]
            for x in range(self.block_size): #create the horizontal projection
                for y in range(self.block_size):
                    h_values[x,y] = (self.block_size-1-x)*self.left_ref[y] + (x+1)*self.top_ref[self.block_size+1]
            #Finally create the planar prediction
            for x in range(self.block_size):
                for y in range(self.block_size):
                    self.pred_out[x,y] = int((v_values[x,y]+h_values[x,y]+self.block_size)/(2*self.block_size)) #cast to integer
                    
        except ValueError:
            print('Invalid values in the reference samples or block size')
        except Exception as err:
            print('Error in the Planar prediction: {}'.format(err))
        else:
            #Re-scale the prediction values to [0-255] range
            max_value = np.amax(self.pred_out)
            min_value = np.amin(self.pred_out)
            self.pred_out = ((self.pred_out-min_value)/(max_value-min_value))*255
            self.pred_out  = self.pred_out.astype(int)
            return self.pred_out

    #all 35 angular predictions
    def intra_prediction_angular(self,mode):
        '''
        Generates an angular prediction from a given context
        '''
        #select the main reference depending on the mode]
        mode_displacement = [32,26,21,17,13,9,5,2]
        mode_displacement_inv = [2,5,9,13,17,21,26,32] 
        main_reference = []
        # pred_angular = np.zeros((self.block_size,self.block_size)) #prediction output
        if(mode >= 2 and mode < 18):#left context is the main reference for these modes
            main_reference = self.left_ref
            main_reference_ext = [] #extension used for modes with negative displacement
            positive_modes = [mode for mode in range(2,10)]
            negative_modes = [mode for mode in range(11,18)]#handle with inverse angles when extedinding the reference samples
            #set the mode displacement
            displacement = 0
            if(mode in positive_modes and mode != 10):
                displacement = mode_displacement[positive_modes.index(mode)]
                #predictions for modes with positive displacement
                for x in range(self.block_size):
                    for y in range(self.block_size):
                        #calculate the pixel projection on to the reference array
                        c = (y*displacement)>>5 
                        w = (y*displacement) and 31
                        i = x + c
                        #estimate the pixel value from the neighboring projections
                        self.pred_out[x,y] = int(((32-w)*main_reference[i] + w*main_reference[i+1]+16)/32)

            elif(mode==10 ):
                for i in range(self.block_size):
                    for j in range(self.block_size):
                        self.pred_out[i,j] = main_reference[i] #pure horizontal prediction
            else:
                displacement = -(mode_displacement_inv[negative_modes.index(mode)])
                inv_angle = (256*32)/displacement #compute an equivalent of the negative angle
                #extend the main reference according to the negative prediction directions
                for i in range(1,self.block_size):
                    index = -1+(int(-i*inv_angle+128)>>8)
                    if(index<=self.block_size-1):
                        main_reference_ext.append(self.top_ref[index])
                #create a new reference array with extension for negative angles
                extension_len = len(main_reference_ext)
                #insert the top left context to the left ref array
                main_reference = np.insert(main_reference,0,self.top_ref[0])
                for val in main_reference_ext:
                    main_reference = np.insert(main_reference,0,val)
                #prediction for modes with negative displacement
                for x in range(self.block_size):
                    for y in range(self.block_size):
                        c = (y*displacement)>>5
                        w = (y*displacement) and 31
                        i = x + c
                        #if i is negative use the extended reference array 
                        self.pred_out[x,y] = int(((32-w)*main_reference[i+1+extension_len] + w*main_reference[i+2+extension_len]+16)/32)
        else:#top reference is used otherwise
            main_reference = self.top_ref
            main_reference_ext = []
            positive_modes = [mode for mode in range(26,35)]
            negative_modes = [mode for mode in range(18,26)]
            if(mode in positive_modes and mode != 26):
                displacement = mode_displacement_inv[positive_modes.index(mode)-1]
                for x in range(self.block_size):
                    for y in range(self.block_size):
                        c = (y*displacement)>>5
                        w = (y*displacement) and 31
                        i = x + c
                        self.pred_out[x,y] = int(((32-w)*main_reference[i+1] + w*main_reference[i+2]+16)/32)
            elif(mode==26): #pure vertical prediction
                for i in range(self.block_size):
                    for j in range(self.block_size):
                        self.pred_out[i,j] = main_reference[j+1]
            else:
                displacement = -(mode_displacement[negative_modes.index(mode)])
                inv_angle = (256*32)/displacement
                #extend the main reference according to the negative prediction directions
                for i in range(1,self.block_size):
                    index = -1+(int(-i*inv_angle+128)>>8)
                    if(index<=self.block_size-1):
                        main_reference_ext.append(self.left_ref[index])
                #create a new reference array with extension for negative angles
                extension_len = len(main_reference_ext)
                for val in main_reference_ext:
                    main_reference = np.insert(main_reference,0,val)
                for x in range(self.block_size):
                    for y in range(self.block_size):
                        c = (y*displacement)>>5
                        w = (y*displacement) and 31
                        i = x + c 
                        self.pred_out[x,y] = int(((32-w)*main_reference[i+1+extension_len] + w*main_reference[i+2+extension_len]+16)/32)
        return self.pred_out

      