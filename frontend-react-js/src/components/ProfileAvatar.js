import './ProfileAvatar.css';

export default function ProfileAvatar({ id }) {
  //const backgroundImage = `url("https://assets.cruddur.com/avatars/${props.id}.jpg")`;
  const backgroundImage = id != null ? `url("https://assets.globalphidelist.tech/avatars/${id}.jpg")` :"none";
  const styles = {
    backgroundImage,
    backgroundSize: 'cover',
    backgroundPosition: 'center',
  };

  return (
    <div 
      className="profile-avatar"
      style={styles}
    ></div>
  );
}