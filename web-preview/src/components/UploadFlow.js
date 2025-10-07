import React, { useState, useRef } from 'react';
import styled, { keyframes } from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';

const shimmer = keyframes`
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
`;

const Container = styled.div`
  height: 100%;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
`;

const FilmGrainOverlay = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 50%, transparent 20%, rgba(255,255,255,0.005) 21%, rgba(255,255,255,0.005) 34%, transparent 35%, transparent),
    linear-gradient(0deg, transparent 24%, rgba(255,255,255,0.01) 25%, rgba(255,255,255,0.01) 26%, transparent 27%, transparent 74%, rgba(255,255,255,0.01) 75%, rgba(255,255,255,0.01) 76%, transparent 77%, transparent);
  pointer-events: none;
  mix-blend-mode: overlay;
  z-index: 1;
`;

const Header = styled.div`
  display: flex;
  align-items: center;
  padding: 20px;
  background: rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  position: relative;
  z-index: 2;
`;

const BackButton = styled(motion.button)`
  background: none;
  border: none;
  color: white;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 12px;
  margin-right: 16px;
  transition: all 0.3s ease;
  
  &:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: scale(1.1);
  }
`;

const Title = styled.h1`
  color: white;
  font-size: 24px;
  font-weight: 800;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
  letter-spacing: -0.5px;
`;

const Content = styled.div`
  flex: 1;
  padding: 20px;
  position: relative;
  z-index: 2;
  overflow-y: auto;
`;

const StepIndicator = styled.div`
  display: flex;
  justify-content: center;
  margin-bottom: 30px;
`;

const StepDot = styled(motion.div)`
  width: 12px;
  height: 12px;
  border-radius: 6px;
  background: ${props => props.active ? '#FF6B6B' : 'rgba(255, 255, 255, 0.3)'};
  margin: 0 6px;
  box-shadow: ${props => props.active ? '0 2px 8px rgba(255, 107, 107, 0.4)' : 'none'};
`;

const StepContainer = styled(motion.div)`
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 30px;
  margin-bottom: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
`;

const StepShimmer = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.2),
    transparent
  );
  animation: ${shimmer} 3s infinite;
  opacity: 0.3;
`;

const StepTitle = styled.h2`
  color: #1a1a2e;
  font-size: 24px;
  font-weight: 800;
  margin: 0 0 20px 0;
  letter-spacing: -0.5px;
`;

const UploadArea = styled(motion.div)`
  border: 3px dashed ${props => props.dragOver ? '#FF6B6B' : '#ccc'};
  border-radius: 16px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: ${props => props.dragOver ? 'rgba(255, 107, 107, 0.1)' : 'rgba(0,0,0,0.02)'};
  position: relative;
  overflow: hidden;
  
  &:hover {
    border-color: #FF6B6B;
    background: rgba(255, 107, 107, 0.05);
  }
`;

const UploadIcon = styled(motion.div)`
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.7;
`;

const UploadText = styled.p`
  color: #666;
  font-size: 16px;
  margin: 0 0 8px 0;
  font-weight: 600;
`;

const UploadSubtext = styled.p`
  color: #999;
  font-size: 14px;
  margin: 0;
`;

const VideoPreview = styled.div`
  background: #000;
  border-radius: 12px;
  margin: 20px 0;
  overflow: hidden;
  position: relative;
`;

const VideoElement = styled.video`
  width: 100%;
  height: 200px;
  object-fit: cover;
`;

const VideoOverlay = styled.div`
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
  padding: 12px;
  color: white;
  font-size: 12px;
`;

const MetadataSection = styled.div`
  margin: 24px 0;
`;

const FormGroup = styled.div`
  margin-bottom: 20px;
`;

const Label = styled.label`
  display: block;
  color: #333;
  font-weight: 700;
  margin-bottom: 8px;
  font-size: 14px;
`;

const Input = styled.input`
  width: 100%;
  padding: 14px;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 16px;
  box-sizing: border-box;
  transition: all 0.3s ease;
  
  &:focus {
    outline: none;
    border-color: #FF6B6B;
    box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.1);
  }
`;

const DateTimeRow = styled.div`
  display: flex;
  gap: 12px;
`;

const TimestampResolution = styled(motion.div)`
  background: rgba(255, 215, 0, 0.1);
  border: 1px solid rgba(255, 215, 0, 0.3);
  border-radius: 12px;
  padding: 16px;
  margin: 16px 0;
`;

const ResolutionTitle = styled.h4`
  color: #B8860B;
  font-size: 14px;
  font-weight: 700;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  gap: 8px;
`;

const ResolutionText = styled.p`
  color: #666;
  font-size: 13px;
  margin: 0;
  line-height: 1.4;
`;

const TimelinePreview = styled.div`
  background: rgba(0, 0, 0, 0.05);
  border-radius: 12px;
  padding: 20px;
  margin: 20px 0;
`;

const TimelineTitle = styled.h4`
  color: #333;
  font-size: 16px;
  font-weight: 700;
  margin: 0 0 12px 0;
`;

const TimelineBar = styled.div`
  display: flex;
  align-items: center;
  gap: 4px;
  height: 20px;
  margin: 12px 0;
`;

const TimelineClip = styled(motion.div)`
  height: 20px;
  background: ${props => props.color};
  border-radius: 4px;
  position: relative;
  min-width: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 10px;
  font-weight: 600;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
`;

const NewClipIndicator = styled(motion.div)`
  height: 20px;
  background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%);
  border-radius: 4px;
  min-width: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 10px;
  font-weight: 700;
  box-shadow: 0 4px 8px rgba(255, 107, 107, 0.4);
  border: 2px solid white;
`;

const TimelineLabels = styled.div`
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: #666;
  margin-top: 8px;
`;

const ButtonRow = styled.div`
  display: flex;
  gap: 12px;
  margin-top: 30px;
`;

const Button = styled(motion.button)`
  flex: 1;
  padding: 16px;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  
  &.primary {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%);
    color: white;
    box-shadow: 0 8px 16px rgba(255, 107, 107, 0.4);
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 12px 24px rgba(255, 107, 107, 0.5);
    }
    
    &:disabled {
      background: #ccc;
      box-shadow: none;
      transform: none;
      cursor: not-allowed;
    }
  }
  
  &.secondary {
    background: rgba(0, 0, 0, 0.05);
    color: #666;
    border: 2px solid #e0e0e0;
    
    &:hover {
      background: rgba(0, 0, 0, 0.1);
      border-color: #ccc;
    }
  }
`;

const ProgressOverlay = styled(motion.div)`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 100;
`;

const ProgressSpinner = styled(motion.div)`
  width: 60px;
  height: 60px;
  border: 4px solid rgba(255, 255, 255, 0.2);
  border-top: 4px solid #FF6B6B;
  border-radius: 50%;
  margin-bottom: 20px;
`;

const ProgressText = styled.div`
  color: white;
  font-size: 18px;
  font-weight: 600;
  text-align: center;
`;

// Mock existing timeline data
const existingClips = [
  { id: 1, time: '09:15 AM', duration: 45, color: '#4ECDC4', author: 'Sarah' },
  { id: 2, time: '09:43 AM', duration: 30, color: '#45B7D1', author: 'Mike' },
  { id: 3, time: '10:22 AM', duration: 60, color: '#96CEB4', author: 'Emma' },
  { id: 4, time: '11:15 AM', duration: 38, color: '#FFEAA7', author: 'You' }
];

const UploadFlow = ({ onNavigate, capsuleName = "Summer Road Trip 2024" }) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [selectedFile, setSelectedFile] = useState(null);
  const [dragOver, setDragOver] = useState(false);
  const [metadata, setMetadata] = useState({
    title: '',
    recordedDate: '',
    recordedTime: ''
  });
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef(null);

  const handleFileSelect = (file) => {
    if (file && file.type.startsWith('video/')) {
      setSelectedFile(file);
      
      // Extract video metadata for chronological ordering
      // Use file's last modified date as a fallback for when video was taken
      const fileDate = new Date(file.lastModified || file.dateCreated || Date.now());
      
      setMetadata({
        title: file.name.replace(/\.[^/.]+$/, "").replace(/[_-]/g, ' '),
        recordedDate: fileDate.toISOString().split('T')[0],
        recordedTime: fileDate.toTimeString().split(' ')[0].substring(0, 5)
      });
      
      setCurrentStep(1);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files[0];
    handleFileSelect(file);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setDragOver(false);
  };

  const calculateInsertionPosition = () => {
    const uploadTime = new Date(`${metadata.recordedDate}T${metadata.recordedTime}`);
    const insertAfter = existingClips.findIndex((clip, index) => {
      const nextClip = existingClips[index + 1];
      if (!nextClip) return true;
      
      const currentTime = new Date(`2024-08-20T${clip.time.replace(' AM', '').replace(' PM', '')}`);
      const nextTime = new Date(`2024-08-20T${nextClip.time.replace(' AM', '').replace(' PM', '')}`);
      
      return uploadTime > currentTime && uploadTime < nextTime;
    });
    
    return insertAfter;
  };

  const handleUpload = () => {
    setIsUploading(true);
    setCurrentStep(2);
    
    // Simulate upload process
    setTimeout(() => {
      setIsUploading(false);
      setTimeout(() => {
        onNavigate('capsuleDetail');
      }, 1000);
    }, 3000);
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 0:
        return (
          <StepContainer
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <StepShimmer />
            <StepTitle>Select Video</StepTitle>
            
            <UploadArea
              dragOver={dragOver}
              onClick={() => fileInputRef.current?.click()}
              onDrop={handleDrop}
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <UploadIcon
                animate={dragOver ? { scale: 1.1 } : { scale: 1 }}
              >
                📁
              </UploadIcon>
              <UploadText>
                {dragOver ? 'Drop your video here!' : 'Choose video or drag & drop'}
              </UploadText>
              <UploadSubtext>
                Supports MP4, MOV, AVI up to 100MB
              </UploadSubtext>
            </UploadArea>
            
            <input
              ref={fileInputRef}
              type="file"
              accept="video/*"
              onChange={(e) => handleFileSelect(e.target.files[0])}
              style={{ display: 'none' }}
            />
          </StepContainer>
        );
        
      case 1:
        return (
          <StepContainer
            initial={{ opacity: 0, x: 100 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
          >
            <StepShimmer />
            <StepTitle>Video Details</StepTitle>
            
            {selectedFile && (
              <VideoPreview>
                <VideoElement
                  src={URL.createObjectURL(selectedFile)}
                  controls
                />
                <VideoOverlay>
                  {selectedFile.name} • {(selectedFile.size / 1024 / 1024).toFixed(1)}MB
                </VideoOverlay>
              </VideoPreview>
            )}
            
            <MetadataSection>
              <FormGroup>
                <Label>Video Title</Label>
                <Input
                  type="text"
                  value={metadata.title}
                  onChange={(e) => setMetadata({...metadata, title: e.target.value})}
                  placeholder="Enter a title for this video"
                />
              </FormGroup>
              
              <FormGroup>
                <Label>When was this recorded?</Label>
                <DateTimeRow>
                  <Input
                    type="date"
                    value={metadata.recordedDate}
                    onChange={(e) => setMetadata({...metadata, recordedDate: e.target.value})}
                  />
                  <Input
                    type="time"
                    value={metadata.recordedTime}
                    onChange={(e) => setMetadata({...metadata, recordedTime: e.target.value})}
                  />
                </DateTimeRow>
              </FormGroup>
              
              <TimestampResolution
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
              >
                <ResolutionTitle>
                  ⏰ Chronological Insertion
                </ResolutionTitle>
                <ResolutionText>
                  Your video will be automatically placed in the correct chronological order based on when it was recorded. This ensures your final time capsule plays as one seamless story.
                </ResolutionText>
              </TimestampResolution>
              
              <TimelinePreview>
                <TimelineTitle>Timeline Preview</TimelineTitle>
                <TimelineBar>
                  {existingClips.map((clip, index) => {
                    const insertPos = calculateInsertionPosition();
                    return (
                      <React.Fragment key={clip.id}>
                        <TimelineClip
                          color={clip.color}
                          style={{ width: `${clip.duration}px` }}
                          initial={{ opacity: 0, scale: 0.8 }}
                          animate={{ opacity: 1, scale: 1 }}
                          transition={{ delay: index * 0.1 }}
                        >
                          {clip.author.charAt(0)}
                        </TimelineClip>
                        {index === insertPos && (
                          <NewClipIndicator
                            initial={{ opacity: 0, scale: 0 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ delay: 0.5, type: "spring" }}
                          >
                            NEW
                          </NewClipIndicator>
                        )}
                      </React.Fragment>
                    );
                  })}
                </TimelineBar>
                <TimelineLabels>
                  <span>9:15 AM</span>
                  <span>Your video will be inserted at {metadata.recordedTime}</span>
                  <span>11:15 AM</span>
                </TimelineLabels>
              </TimelinePreview>
            </MetadataSection>
            
            <ButtonRow>
              <Button
                className="secondary"
                onClick={() => setCurrentStep(0)}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                Choose Different Video
              </Button>
              <Button
                className="primary"
                onClick={handleUpload}
                disabled={!metadata.title || !metadata.recordedDate || !metadata.recordedTime}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                Add to Capsule
              </Button>
            </ButtonRow>
          </StepContainer>
        );
        
      case 2:
        return (
          <StepContainer
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6 }}
          >
            <StepTitle>Adding to Capsule</StepTitle>
            <div style={{ textAlign: 'center', padding: '40px 0' }}>
              <motion.div
                style={{ fontSize: '64px', marginBottom: '20px' }}
                animate={{ rotate: 360 }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              >
                ⏳
              </motion.div>
              <p style={{ color: '#666', fontSize: '16px', margin: 0 }}>
                Processing your video and placing it in chronological order...
              </p>
            </div>
          </StepContainer>
        );
        
      default:
        return null;
    }
  };

  return (
    <Container>
      <FilmGrainOverlay />
      
      <Header>
        <BackButton
          onClick={() => onNavigate('capsuleDetail')}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.95 }}
        >
          ←
        </BackButton>
        <Title>Upload to {capsuleName}</Title>
      </Header>
      
      <Content>
        <StepIndicator>
          {[0, 1, 2].map((step) => (
            <StepDot
              key={step}
              active={currentStep >= step}
              animate={currentStep >= step ? { scale: [1, 1.2, 1] } : {}}
              transition={{ duration: 0.3 }}
            />
          ))}
        </StepIndicator>
        
        <AnimatePresence mode="wait">
          {renderStepContent()}
        </AnimatePresence>
      </Content>
      
      {isUploading && (
        <ProgressOverlay
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <ProgressSpinner
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
          />
          <ProgressText>
            Uploading and processing...
            <br />
            <small>This may take a moment</small>
          </ProgressText>
        </ProgressOverlay>
      )}
    </Container>
  );
};

export default UploadFlow;