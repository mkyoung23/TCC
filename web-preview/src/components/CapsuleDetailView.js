import React, { useState } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';

const Container = styled.div`
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
`;

const Header = styled.div`
  padding: 20px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
`;

const BackButton = styled.button`
  background: none;
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  margin-right: 16px;
`;

const HeaderInfo = styled.div`
  flex: 1;
`;

const Title = styled.h1`
  color: white;
  font-size: 20px;
  font-weight: 700;
  margin: 0 0 4px 0;
`;

const Subtitle = styled.p`
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  margin: 0;
`;

const CountdownSection = styled.div`
  padding: 30px 20px;
  text-align: center;
  background: rgba(255, 255, 255, 0.05);
`;

const CountdownTitle = styled.h2`
  color: white;
  font-size: 18px;
  margin-bottom: 16px;
`;

const CountdownTimer = styled.div`
  background: rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 20px;
  backdrop-filter: blur(10px);
`;

const TimeNumber = styled.div`
  color: white;
  font-size: 36px;
  font-weight: 700;
  margin-bottom: 4px;
`;

const TimeLabel = styled.div`
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
`;

const TabSection = styled.div`
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const TabBar = styled.div`
  display: flex;
  padding: 0 20px;
  background: rgba(255, 255, 255, 0.05);
`;

const Tab = styled.button`
  flex: 1;
  padding: 16px;
  background: none;
  border: none;
  color: ${props => props.active ? 'white' : 'rgba(255, 255, 255, 0.6)'};
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  border-bottom: 2px solid ${props => props.active ? 'white' : 'transparent'};
`;

const TabContent = styled.div`
  flex: 1;
  padding: 20px;
  overflow-y: auto;
`;

const VideoGrid = styled.div`
  display: grid;
  gap: 12px;
`;

const VideoCard = styled(motion.div)`
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
`;

const VideoThumbnail = styled.div`
  width: 60px;
  height: 60px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
`;

const VideoInfo = styled.div`
  flex: 1;
`;

const VideoTitle = styled.div`
  color: white;
  font-weight: 600;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
`;

const VideoType = styled.span`
  background: ${props => props.type === 'recorded' ? '#FF9500' : '#007AFF'};
  color: white;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 500;
`;

const VideoMeta = styled.div`
  color: rgba(255, 255, 255, 0.7);
  font-size: 12px;
  
  .duration {
    color: rgba(255, 255, 255, 0.9);
    font-weight: 500;
  }
`;

const MembersList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 12px;
`;

const MemberCard = styled.div`
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
`;

const MemberAvatar = styled.div`
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
`;

const MemberInfo = styled.div`
  flex: 1;
`;

const MemberName = styled.div`
  color: white;
  font-weight: 600;
  margin-bottom: 2px;
`;

const MemberStatus = styled.div`
  color: rgba(255, 255, 255, 0.7);
  font-size: 12px;
`;

const AddButtonContainer = styled.div`
  position: fixed;
  bottom: 100px;
  right: 30px;
  display: flex;
  flex-direction: column;
  gap: 12px;
`;

const AddButton = styled(motion.button)`
  width: 56px;
  height: 56px;
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.9);
  border: none;
  color: #4c63d2;
  font-size: 20px;
  cursor: pointer;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
`;

const ActionMenu = styled(motion.div)`
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(10px);
  min-width: 200px;
`;

const ActionButton = styled.button`
  width: 100%;
  padding: 16px;
  background: none;
  border: none;
  color: #4c63d2;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  border-radius: 12px;
  margin-bottom: 8px;
  text-align: left;
  display: flex;
  align-items: center;
  gap: 12px;
  
  &:hover {
    background: rgba(76, 99, 210, 0.1);
  }
  
  &:last-child {
    margin-bottom: 0;
  }
`;

const RecordingModal = styled(motion.div)`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 1000;
`;

const RecordingInterface = styled.div`
  text-align: center;
  color: white;
`;

const RecordButton = styled(motion.button)`
  width: 80px;
  height: 80px;
  border-radius: 40px;
  background: #FF3B30;
  border: 4px solid white;
  margin: 20px;
  cursor: pointer;
  
  &.recording {
    background: #FF9500;
    animation: pulse 1.5s infinite;
  }
  
  @keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.1); }
    100% { transform: scale(1); }
  }
`;

const ModalOverlay = styled(motion.div)`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
`;

const UploadModal = styled(motion.div)`
  background: white;
  border-radius: 16px;
  padding: 24px;
  max-width: 300px;
  width: 90%;
  text-align: center;
`;

const UploadArea = styled.div`
  border: 2px dashed #ccc;
  border-radius: 12px;
  padding: 40px 20px;
  margin: 20px 0;
  cursor: pointer;
  
  &:hover {
    border-color: #4c63d2;
    background: rgba(76, 99, 210, 0.05);
  }
`;

const MetadataForm = styled.div`
  text-align: left;
  margin-top: 20px;
`;

const FormGroup = styled.div`
  margin-bottom: 16px;
`;

const Label = styled.label`
  display: block;
  color: #333;
  font-weight: 600;
  margin-bottom: 6px;
`;

const Input = styled.input`
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  box-sizing: border-box;
`;

const mockVideos = [
  { 
    id: 1, 
    title: "Day 1 - Packing up!", 
    author: "Sarah", 
    date: "2 days ago",
    timestamp: "2024-08-18T10:30:00Z",
    type: "upload",
    duration: "2:15"
  },
  { 
    id: 2, 
    title: "Road trip begins", 
    author: "Mike", 
    date: "1 day ago",
    timestamp: "2024-08-19T08:45:00Z",
    type: "recorded",
    duration: "1:45"
  },
  { 
    id: 3, 
    title: "First stop - Grand Canyon", 
    author: "Emma", 
    date: "6 hours ago",
    timestamp: "2024-08-20T12:15:00Z",
    type: "upload",
    duration: "3:20"
  }
].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp)); // Chronological order

const mockMembers = [
  { id: 1, name: "Sarah Johnson", status: "3 videos", avatar: "👩" },
  { id: 2, name: "Mike Chen", status: "2 videos", avatar: "👨" },
  { id: 3, name: "Emma Davis", status: "1 video", avatar: "👱‍♀️" },
  { id: 4, name: "You", status: "Owner", avatar: "😊" }
];

const CapsuleDetailView = ({ onNavigate }) => {
  const [activeTab, setActiveTab] = useState('videos');
  const [showActionMenu, setShowActionMenu] = useState(false);
  const [showRecording, setShowRecording] = useState(false);
  const [showUpload, setShowUpload] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const [videoMetadata, setVideoMetadata] = useState({
    title: '',
    recordedDate: '',
    recordedTime: ''
  });

  const handleFileSelect = (event) => {
    const file = event.target.files[0];
    if (file && file.type.startsWith('video/')) {
      setSelectedFile(file);
      // Extract metadata from file
      setVideoMetadata({
        title: file.name.replace(/\.[^/.]+$/, ""),
        recordedDate: new Date().toISOString().split('T')[0],
        recordedTime: new Date().toTimeString().split(' ')[0].substring(0, 5)
      });
    }
  };

  const handleUploadVideo = () => {
    // In real app: upload to Firebase with proper timestamp for chronological order
    console.log('Uploading video with metadata:', {
      file: selectedFile,
      ...videoMetadata,
      timestamp: new Date(`${videoMetadata.recordedDate}T${videoMetadata.recordedTime}`).toISOString()
    });
    setShowUpload(false);
    setSelectedFile(null);
  };

  const startRecording = () => {
    setIsRecording(true);
    // In real app: start camera recording with timestamp
    console.log('Started recording at:', new Date().toISOString());
  };

  const stopRecording = () => {
    setIsRecording(false);
    // In real app: stop recording and save with current timestamp
    console.log('Stopped recording at:', new Date().toISOString());
    setShowRecording(false);
  };

  return (
    <Container>
      <Header>
        <BackButton onClick={() => onNavigate('capsuleList')}>
          ←
        </BackButton>
        <HeaderInfo>
          <Title>Family Vacation 2024</Title>
          <Subtitle>4 members • 8 videos</Subtitle>
        </HeaderInfo>
      </Header>
      
      <CountdownSection>
        <CountdownTitle>Unseals in</CountdownTitle>
        <CountdownTimer>
          <TimeNumber>127</TimeNumber>
          <TimeLabel>days</TimeLabel>
        </CountdownTimer>
      </CountdownSection>
      
      <TabSection>
        <TabBar>
          <Tab
            active={activeTab === 'videos'}
            onClick={() => setActiveTab('videos')}
          >
            Videos
          </Tab>
          <Tab
            active={activeTab === 'members'}
            onClick={() => setActiveTab('members')}
          >
            Members
          </Tab>
        </TabBar>
        
        <TabContent>
          {activeTab === 'videos' && (
            <VideoGrid>
              {mockVideos.map((video, index) => (
                <VideoCard
                  key={video.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <VideoThumbnail>🎥</VideoThumbnail>
                  <VideoInfo>
                    <VideoTitle>
                      {video.title}
                      <VideoType type={video.type}>
                        {video.type === 'recorded' ? 'REC' : 'UPLOAD'}
                      </VideoType>
                    </VideoTitle>
                    <VideoMeta>
                      by {video.author} • {video.date} • <span className="duration">{video.duration}</span>
                    </VideoMeta>
                  </VideoInfo>
                </VideoCard>
              ))}
            </VideoGrid>
          )}
          
          {activeTab === 'members' && (
            <MembersList>
              {mockMembers.map((member, index) => (
                <MemberCard key={member.id}>
                  <MemberAvatar>{member.avatar}</MemberAvatar>
                  <MemberInfo>
                    <MemberName>{member.name}</MemberName>
                    <MemberStatus>{member.status}</MemberStatus>
                  </MemberInfo>
                </MemberCard>
              ))}
            </MembersList>
          )}
        </TabContent>
      </TabSection>
      
      <AddButton
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
      >
        +
      </AddButton>
    </Container>
  );
};

export default CapsuleDetailView;